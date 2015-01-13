#!/usr/bin/env python
import os
import sys


if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")

    from django.contrib.auth.models import UserManager
    from django.contrib.auth.models import User
    from django.db import IntegrityError
    from django.contrib.auth.models import User

    mgmt = UserManager()
    mgmt.model = User
    #import ipdb;ipdb.set_trace()
    try: 
      mgmt.create_superuser(sys.argv[1], sys.argv[2], sys.argv[3])
    # reset password if user exist ...
    except IntegrityError:
      u = User.objects.get(username__exact=sys.argv[1])
      u.set_password(sys.argv[3])
      u.save()

