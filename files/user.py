#!/usr/bin/env python
import os
import sys


if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")

    from django.contrib.auth.models import UserManager
    from django.contrib.auth.models import User

    mgmt = UserManager()
    mgmt.model = User
    mgmt.create_superuser(sys.argv[1], sys.argv[2], sys.argv[3])
