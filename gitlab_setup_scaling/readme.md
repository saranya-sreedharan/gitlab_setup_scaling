contain 2 scripts:
part1.sh and part2.sh

( docker, docker-compose should be installed)

Part1.sh:
------------------
it will create neccessary files in the location
then it will create a gitlab and gitlab runner (same method we done initially- direct docker command not docker-compose used that time )
take the password and login to the gitlab

username : root
password_location: /etc/gitlab/initial_root_password

part2.sh:
---------------------------
this will take the backup of gitlab and stored in the specific location. Then stop and remove the gitlab and gitlab runner. 
then using that backup it will create gitlab and gitlab runner. 
once it is up and running using same docker-compse file we can scale gitlab runner.
