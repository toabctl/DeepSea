{% set label = "force" %}

Disengage {{ label }}:
  salt.runner:
    - name: disengage.safety

forced removal:
  salt.runner:
    - name: osd.replace
    - arg:
      - 0
    - kwarg:
      force: True

Check OSDs {{ label }}:
  salt.state:
    - tgt: {{ salt['master.minion']() }}
    - sls: ceph.tests.replace.check_0

Restore OSDs {{ label }}:
  salt.runner:
    - name: disks.deploy

Wait for Ceph {{ label }}:
  salt.state:
    - tgt: {{ salt['master.minion']() }}
    - sls: ceph.wait.until.OK
