{% if grains.get('os', '') == 'CentOS' %}
install_prometheus_repo:
  pkgrepo.managed:
    - name: prometheus-rpm_release
    - humanname: Prometheus release repo
    - baseurl: https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch
    - gpgcheck: False
    - enabled: True
    - fire_event: True

install_prometheus:
  pkg.installed:
    - name: prometheus
    - refresh: True
    - fire_event: True

{% else %}

golang-github-prometheus-prometheus:
  pkg.installed:
    - fire_event: True
    - name: golang-github-prometheus-prometheus
    - refresh: True

ceph-prometheus-alerts:
  pkg.installed:
    - fire_event: True
    - name: ceph-prometheus-alerts
    - refresh: True

{% endif %}

/etc/prometheus/prometheus.yml:
  file.managed:
    - source: salt://ceph/monitoring/prometheus/files/prometheus.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - fire_event: True

{% if salt['pillar.get']('monitoring:prometheus:additional_flags', False) %}
/etc/sysconfig/prometheus:
  file.managed:
    - content: ARGS="{{ pillar['monitoring:prometheus:additional_flags'] }}"
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - fire_event: True
    - watch_in:
      - service: prometheus
{% endif %}

{% for rule_file in salt['pillar.get']('monitoring:prometheus:rule_files', []) %}
{% set file_name = salt['cmd.shell']("basename" + rule_file) %}
/etc/prometheus/SUSE/custom_rules/{{ file_name }}:
  file.managed:
    - source: {{ rule_file }}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - fire_event: True
{% endfor %}

start prometheus:
  service.running:
    - name: prometheus
    - enable: True
    - restart: True
    - watch:
      - file: /etc/prometheus/prometheus.yml
