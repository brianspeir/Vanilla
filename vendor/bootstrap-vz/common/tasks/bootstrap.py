from base import Task
from common import phases
from common.exceptions import TaskError
import logging
log = logging.getLogger(__name__)


def get_bootstrap_args(info):
	executable = ['/usr/sbin/debootstrap']
	options = ['--arch=' + info.manifest.system['architecture']]
	if len(info.include_packages) > 0:
		options.append('--include=' + ','.join(info.include_packages))
	if len(info.exclude_packages) > 0:
		options.append('--exclude=' + ','.join(info.exclude_packages))
	mirror = info.manifest.bootstrapper.get('mirror', info.apt_mirror)
	arguments = [info.manifest.system['release'], info.root, mirror]
	return executable, options, arguments


class MakeTarball(Task):
	description = 'Creating bootstrap tarball'
	phase = phases.os_installation

	@classmethod
	def run(cls, info):
		from hashlib import sha1
		import os.path
		executable, options, arguments = get_bootstrap_args(info)
		# Filter info.root which points at /target/volume-id, we won't ever hit anything with that in there.
		hash_args = [arg for arg in arguments if arg != info.root]
		tarball_id = sha1(repr(frozenset(options + hash_args))).hexdigest()[0:8]
		tarball_filename = 'debootstrap-{id}.tar'.format(id=tarball_id)
		info.tarball = os.path.join(info.manifest.bootstrapper['workspace'], tarball_filename)
		if os.path.isfile(info.tarball):
			log.debug('Found matching tarball, skipping download')
		else:
			from common.tools import log_call
			status, out, err = log_call(executable + options + ['--make-tarball=' + info.tarball] + arguments)
			if status != 1:
				msg = 'debootstrap exited with status {status}, it should exit with status 1'.format(status=status)
				raise TaskError(msg)


class Bootstrap(Task):
	description = 'Installing Debian'
	phase = phases.os_installation
	predecessors = [MakeTarball]

	@classmethod
	def run(cls, info):
		executable, options, arguments = get_bootstrap_args(info)
		if hasattr(info, 'tarball'):
			options.extend(['--unpack-tarball=' + info.tarball])

		from common.tools import log_check_call
		log_check_call(executable + options + arguments)
