#! /bin/sh
cp -r distro-build-config distro-build-config-nightly
cd distro-build-config-nightly
./step0-lb_clean.sh && ./step1-lb_config.sh && ./step2-get_keys.sh && ./step3-source_lists.sh && ./step4-package_lists.sh && ./step5-etc_settings.sh && ./step6-user_settings.sh && ./step7-final_build.sh