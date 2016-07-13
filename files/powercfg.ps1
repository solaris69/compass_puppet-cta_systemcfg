# sets the power configuration to High Perf (8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
powercfg /s SCHEME_MIN

# turns hibernation off (9d7815a6-7ee4-497e-8888-515a05f02364)
powercfg /hibernate OFF
powercfg /x hibernate-timeout-ac 0
powercfg /x hibernate-timeout-dc 0

# turns monitor timeout off (3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e)
powercfg /x monitor-timeout-ac 0
powercfg /x monitor-timeout-dc 0

# turns hard disk timeout off (6738e2c4-e8a5-4a42-b16a-e040e769756e)
powercfg /x disk-timeout-ac 0
powercfg /x disk-timeout-dc 0

# turns standby timeout off
powercfg /x standby-timeout-ac 0
powercfg /x standby-timeout-dc 0

# turns sleep timeout off
powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0

# do not require password on wakeup
powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c fea3413e-7e05-4911-9a71-700331f1c294 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 0
powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c fea3413e-7e05-4911-9a71-700331f1c294 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 0

exit 0