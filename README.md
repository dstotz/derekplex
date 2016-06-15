# DerekPlex
Simple web server to redirect my Plex users to different add-ons that run on my media server.

## Setup
1. Fork or clone repo
2. Create a project on [Heroku](https://www.heroku.com)
3. Set the following config variables on your Heroku project
    * `SERVER_OWNER_NAME`
    * `SERVER_IP_ADDRESS`
    * `PLEX_REQUEST_PORT`
    * `PLEXPY_PORT`
    * `SONARR_PORT`
4. Deploy your project!

## Local Testing
1. Fork or clone repo
2. Create `.env` file based one `.env.sample`
3. Run `$ ruby app.rb`

## ToDo
* Add stats page
* Add links to the different Plex apps	
* Add link to request access to my server
* Implement single sign on for all Plex add-ons
* Add links to other tools/add-ons
* Add tests
* Setup templating for additional pages

## Thanks
Thank you to the makers of these fine tools that make this little project necessary.  
[Plex Requests](https://github.com/lokenx/plexrequests-meteor)  
[PlexPy](https://github.com/drzoidberg33/plexpy)  
