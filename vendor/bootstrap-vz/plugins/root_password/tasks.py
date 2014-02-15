from base import Task
from common import phases


class SetRootPassword(Task):
	description = 'Setting the root password'
	phase = phases.system_modification

	@classmethod
	def run(cls, info):
		from common.tools import log_check_call
		log_check_call(['/usr/sbin/chroot', info.root, '/usr/sbin/chpasswd'],
		               'root:' + info.manifest.plugins['root_password']['password'])
