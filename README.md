# centos-xrdp-docker
Repo of dockerfile and supporting files for building an image based on centos and running xrdp.  Includes visual studio code.

=== Quick and dirty set up ===
Start up a container 
docker run -d --name xrdp1 -p 33389:3389 [image tag]

Add a user 
docker exec -it xrdp1 bash -i
[root@dbeffeebb6b4 /]# adduser yourusername
[root@dbeffeebb6b4 /]# passwd yourusername
Changing password for user yourusername.
New password:
/usr/share/cracklib/pw_dict.pwd.gz: No such file or directory
BAD PASSWORD: The password fails the dictionary check - error loading dictionary
Retype new password:
passwd: all authentication tokens updated successfully.
[root@dbeffeebb6b4 /]# usermod -a -G sudoers yourusername

Then use remote desktop client to connect to 
localhost:33389

Login with the credentials of the user added.

=== Considerations ===
- If you want to generate persistent data within the container you should use a volume
  You should probably also consider replacing files in your home directory with symlinks to files that are on the volume
