# Testing Infrastructure Guide

## Introduction

In this guide we are going to showcase different approaches to building our browser testing infrastructure. All approaches will use the same application under test and test cases. The following approaches are discussed:

* Selenium Standalone
* Self-hosted Selenium Grid
* BrowserStack: SaaS Product Compatible With Selenium Grid

### Explore

Let's see what's in this repo.

```bash
tree
```

### Install dependencies

```bash
pip install -r requirements.txt
```

## Selenium Standalone

### Start the application under test

```bash
python demoapp/server.py 8080
```

### Run the tests

```bash
robot \
  --variable    BROWSER:"chrome" \
  --variable    SERVER:"localhost:8080" \
  --outputdir   ./test-results/ \
  ./login_tests/
```

## Selenium Grid

### Launch Selenium Grid

Let's inspect our docker-compose file and see what we are going to deploy.

```bash
cat docker-compose.yml
# or if bat is installed to have better syntax highlighting
bat docker-compose.yml
```

We will see that our docker-compose file contains:

- **A containerized version of our application under test**: Simplifies networking, as it's now part of the network managed by docker-compose. There it will be available at `http://application:7272`.
- **Selenium Hub**: Acts as the entrypoint of our Grid.
- **Selenium Nodes (Chrome and Firefox)**: Containers containing the browsers which will run our tests.

Start Selenium Grid locally using docker-compose.

```bash
docker-compose up
```

Now you can checkout the web interface at http://localhost:4444/grid/console. There we can see which browsers have connected to our grid.

> _Note: In case browsers do not connect, prune them at boot:_
>
> ```bash
> docker-compose rm && docker-compose up --remove-orphans
> ```

### Run the tests agains Grid

```bash
robot \
  --variable    BROWSER:"chrome" \
  --variable    REMOTE_URL:"http://localhost:4444/wd/hub" \
  --variable    SERVER:"application:7272" \
  --outputdir   ./test-results/ \
  ./login_tests/
```

Note that we now need to explicitely instruct the browser where to find our application under test. Previously we used the default `localhost:7272`. However, our browser is now running inside its own container, hence `localhost` would refer to the container itself.

## Run tests on BrowserStack

### BrowserStack Credentials

First, we are going to need to get our credentials to access BrowserStack's hosted Selenium Grid comaptible browsers.

You can get your access key at https://automate.browserstack.com/.

```bash
export BROWSERSTACK_USERNAME="adriaanknapen1"
export BROWSERSTACK_ACCESS_KEY="YOUR_SECURE_KEY"

export BROWSERSTACK_URL="https://$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY@hub-cloud.browserstack.com/wd/hub"
```

### Expose our Application Under Test

For generality we are going to use Ngrok instead of BrowerStack's [Local Testing](https://www.browserstack.com/docs/live/local-testing/test-using-local-testing) software. Ngrok exposes a locally running to a publicly accessible domain.

```bash
# If you have ngrok installed
ngrok http 7272

# If you have Node.js installed
npx ngrok http 7272
```

Let's note down the domain where ngrok exposed our application.

```bash
export APPLICATION_URL="da27c99e2e55.ngrok.io"
```

### Run the tests

Now that we have set up browser stack and exposed our locally running application, we can finally run the tests.

```bash
BROWSER="chrome" && \
robot \
  --variable    BROWSER:$BROWSER \
  --variable    REMOTE_URL:$BROWSERSTACK_URL \
  --variable    SERVER:$APPLICATION_URL \
  --outputdir   ./test-results/ \
  ./login_tests/
```

BrowserStack creates videos of all our tests, so let's hop over to https://automate.browserstack.com and see our tests in action.

### Fancy some IE 6 on XP?

Sometimes you have some legacy environments to support.

```bash
BROWSER="IE" && VERSION="6" && \
PLATFORM="XP" && \
robot \
  --variable    BROWSER:$BROWSER \
  --variable    REMOTE_URL:$BROWSERSTACK_URL \
  --variable    DESIRED_CAPABILITIES:platform:$PLATFORM,version:$VERSION \
  --variable    SERVER:$APPLICATION_URL \
  --outputdir   ./test-results/ \
  ./login_tests/
```

## Bonus

### Continuous Integration

See `.github/workflows/` for various approaches to using a local Selenium Grid inside CI.
