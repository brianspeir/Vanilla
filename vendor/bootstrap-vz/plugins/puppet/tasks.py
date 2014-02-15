from base import Task
from common import phases
from common.tasks import apt
from common.tasks import network
import os


class CheckPaths(Task):
	description = 'Checking whether manifest and assets paths exist'
	phase = phases.preparation

	@classmethod
	def run(cls, info):
		from common.exceptions import TaskError
		assets = info.manifest.plugins['puppet']['assets']
		if not os.path.exists(assets):
			msg = 'The assets directory {assets} does not exist.'.format(assets=assets)
			raise TaskError(msg)
		if not os.path.isdir(assets):
			msg = 'The assets path {assets} does not point to a directory.'.format(assets=assets)
			raise TaskError(msg)

		manifest = info.manifest.plugins['puppet']['manifest']
		if not os.path.exists(manifest):
			msg = 'The manifest file {manifest} does not exist.'.format(manifest=manifest)
			raise TaskError(msg)
		if not os.path.isfile(manifest):
			msg = 'The manifest path {manifest} does not point to a file.'.format(manifest=manifest)
			raise TaskError(msg)


class AddPackages(Task):
	description = 'Add puppet package'
	phase = phases.preparation
	predecessors = [apt.AddDefaultSources]

	@classmethod
	def run(cls, info):
		info.packages.add('puppet')


class CopyPuppetAssets(Task):
	description = 'Copying puppet assets'
	phase = phases.system_modification

	@classmethod
	def run(cls, info):
		from shutil import copy
		puppet_path = os.path.join(info.root, 'etc/puppet')
		puppet_assets = info.manifest.plugins['puppet']['assets']
		for abs_prefix, dirs, files in os.walk(puppet_assets):
			prefix = os.path.normpath(os.path.relpath(abs_prefix, puppet_assets))
			for path in dirs:
				full_path = os.path.join(puppet_path, prefix, path)
				if os.path.exists(full_path):
					if os.path.isdir(full_path):
						continue
					else:
						os.remove(full_path)
				os.mkdir(full_path)
			for path in files:
				copy(os.path.join(abs_prefix, path),
				     os.path.join(puppet_path, prefix, path))


class ApplyPuppetManifest(Task):
	description = 'Applying puppet manifest'
	phase = phases.system_modification
	predecessors = [CopyPuppetAssets]
	successors = [network.RemoveHostname, network.RemoveDNSInfo]

	@classmethod
	def run(cls, info):
		with open(os.path.join(info.root, 'etc/hostname')) as handle:
			hostname = handle.read().strip()
		with open(os.path.join(info.root, 'etc/hosts'), 'a') as handle:
			handle.write('127.0.0.1\t{hostname}\n'.format(hostname=hostname))

		from shutil import copy
		pp_manifest = info.manifest.plugins['puppet']['manifest']
		manifest_rel_dst = os.path.join('tmp', os.path.basename(pp_manifest))
		manifest_dst = os.path.join(info.root, manifest_rel_dst)
		copy(pp_manifest, manifest_dst)

		manifest_path = os.path.join('/', manifest_rel_dst)
		from common.tools import log_check_call
		log_check_call(['/usr/sbin/chroot', info.root,
		                '/usr/bin/puppet', 'apply', manifest_path])
		os.remove(manifest_dst)

		from common.tools import sed_i
		hosts_path = os.path.join(info.root, 'etc/hosts')
		sed_i(hosts_path, '127.0.0.1\s*{hostname}\n?'.format(hostname=hostname), '')
