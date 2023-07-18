# Monolithic Artisanal Futures Backend

This contains all the necessary code to stand up the Artisanal Futures backend. This includes multiple FastAPIs, WordPress, and Certbot for SSL on an Debian server.

## Setup for new AWS Lightsail Debian (or any Debian server)

1. Select the virtual server (using the 4GB, 2CPU, 80GB SSD Debian 10 instance)
2. Once it loads up, go to **Networking**
   1. Create a Static IP. This will link the domain up to the instance.
   2. Create rules for IPv4 and v6 for the following ports: **_22, 80, 443, 7070, 7474, 7687, 8000-8005, and 8080_**
3. Go to domain host (currently it is PorkBun), and add a new address record for a subdomain, using the static IP as the answer.
4. Setup your SSH tunnel via VSCode (or just SSH from the homepage of the instance)
5. Once inside the instance, clone the repository and run `sh init.sh`. This will set up Git LFS, Docker, Docker Compose, UFW, and Git.
6. Next, add a **.env** file to the directory. Take a look at the example one provided as reference.
7. Now run `sh clone.sh` to pull the github and gitlab repositories currently part of the backend.
8. Next, `docker-compose build`. For first time build, it will take a while.
9. Finally, `docker-compose up -d` to run everything detached. It will also generate SSL certificates. **_Make sure you have your domain set up! Otherwise it won't launch properly._**

### Adding new services

For the following example, I will be showing you how to add a new FastAPI service. However, this should help with any other service, just keep in mind that the following code isn't just plug and play.

Make sure you add the path (/api/v1/changeMe) to the API. By default, it tries to serve it in /.

```python
SERVICE_PATH=os.environ.get('SERVICE_PATH') or ""

app = FastAPI(openapi_url=SERVICE_PATH+"/openapi.json", docs_url=SERVICE_PATH+"/docs", prefix=SERVICE_PATH)

# I separated the api code to have the ability to include multiple routers per api in the future.
# Take a look at the address api found in gitlab for an example
app.include_router(changeMe, prefix=SERVICE_PATH, tags=['changeMe'])
```

Then make sure you have a Dockerfile in the api directory.

Navigate back to this repo and add it to the `clone.sh` file. (We do this to ensure the most up to date versions of each service and for ease of use).

```bash

changeMeDir="./changeMe-service"

if [ -d "$changeMeDir/.git" ]; then
  echo "Performing git pull in $changeMeDir..."
  cd "$changeMeDir"
  git pull
  cd ..
else
  echo "Performing git clone in $changeMeDir..."
#   It can be either github or gitlab depending on where the repo is.
#   git clone -b main https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/changeMe.git "$changeMe"
  git clone -b main https://$GITHUB_ACCESS@github.com/CSDTs/changeMe.git  "$changeMeDir"
fi
```

Next, add it to the docker-compose. Just make sure to modify the command, service path, data prefx (if pulling from local source) and names to better fit your service.

```docker
  changeMe_service:
    build: ./changeMe-service
    command: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
    volumes:
      - ./changeMe-service/:/app/
      - ./changeMe-service/data/:/data/
    ports:
      - 8001:8000
    environment:
      - DATA_PREFIX=/app
      - SERVICE_PATH=/api/v1/changeMe
```

Next, add the location to the `nginx_config.conf`.

```nginx
    location /api/v1/changeMe {
      proxy_pass http://changeMe_service:8000/api/v1/changeMe;
      add_header Access-Control-Allow-Origin *;
    }
```

Finally, just add the folder to the gitignore to avoid having to add other repository code.

### Notes

#### Wordpress

Currently using a temp database on the same server instance. So if we plan on changing WordPress to something else, updating the database, or something else destructive, make sure to backup the wordpress backend! This also includes the database. Use the Backup Migration app by Migrate. It seems to be the best in what it does.

The theme needs to be modified for JWT auth.

```php
define( 'GRAPHQL_JWT_AUTH_SECRET_KEY', 'replace_with_random_number_string' );


add_action('rest_api_init', 'add_ACF_fields_to_jwt_auth_response');

function add_ACF_fields_to_jwt_auth_response() {
    // Here 'user' is the type of object being retrieved.
    register_rest_field('user',
        'acf', //New Field Name in JSON RESPONSEs
        array(
            'get_callback'    => 'get_user_acf_fields', // custom function name
            'update_callback' => null,
            'schema'          => null,
            )
    );
}

function get_user_acf_fields($user, $field_name, $request) {
    return get_fields('user_'.$user['id']);
}

add_filter('jwt_auth_token_before_dispatch', 'add_ACF_data_to_jwt_auth_response', 10, 2);

function add_ACF_data_to_jwt_auth_response($data, $user) {
    $response = rest_ensure_response($data);
    $user_data = $response->get_data();

    // Here you retrieve the ACF data that you added to the user response.
    $user_data['acf'] = get_user_acf_fields(array('id' => $user->ID), '', null);

    $response->set_data($user_data);

    return $response;
}

 // Security Custom plugin (but adding it here just in case)
defined('ABSPATH') or die("Unauthorized access");
add_filter('jwt_auth_token_before_dispatch', 'add_user_role_response', 10, 2);
function add_user_role_response($data, $user){
        $data['user_id'] = $user->id;
        return $data;
}

```

##### Plugins needed:

- ACF to REST API
- Advanced Custom Fields
- Custom Post Type UI
- JWT Authentication for WP-API
- Simple-JWT-Login
- GraphQL

#### Helpful Links

- [Setup SSL via Docker](https://www.programonaut.com/setup-ssl-with-docker-nginx-and-lets-encrypt/)
- [Setup SSL via Certbot server install](https://macdonaldchika.medium.com/how-to-install-tls-ssl-on-docker-nginx-container-with-lets-encrypt-5bd3bad1fd48)
- [Firewall setup for SSL issues](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-debian-10)
- [Debug SSL connection errors](https://www.makeuseof.com/fix-ssh-connection-refused-error-linux/)
- [Setup docker on Debian 10](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-10)
