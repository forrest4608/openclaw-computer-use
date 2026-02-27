import sys
import time
from camoufox.sync_api import Camoufox

print("Starting camoufox...")
try:
    with Camoufox(
        headless=False,
        os='macos',
        humanize=True,
        persistent_context=True,
        user_data_dir='/Users/zhigangliu/.openclaw/camoufox-profile'
    ) as browser:
        print("Browser started. Opening page...")
        page = browser.new_page()
        
        url = 'https://twitter.com/search?q=AI%20Agent&src=typed_query&f=live'
        print(f"Navigating to {url}")
        page.goto(url)
        
        # Wait a bit for the page to load or redirect
        time.sleep(10)
        
        content = page.content()
        title = page.title()
        print(f"Page title: {title}")
        
        # Save a screenshot to see the current state
        page.screenshot(path="/Users/zhigangliu/projects/zhigang-project/twitter_state.png")
        print("Screenshot saved to twitter_state.png")
        
        if "Log " in title or "Sign " in title or "flow/login" in page.url:
            print("STATUS: NEEDS_LOGIN")
            print("Twitter is redirecting to the login page. You must log in before you can search.")
        elif "captcha" in page.url.lower():
            print("STATUS: CAPTCHA")
            print("A CAPTCHA is required.")
        else:
            print("STATUS: SUCCESS")
            # Try to extract some tweets
            tweets = page.locator("article[data-testid='tweet']").all_text_contents()
            if not tweets:
                print("No tweets found. The page might still be loading or requires login.")
            else:
                for i, t in enumerate(tweets[:3]):
                    print(f"--- Tweet {i+1} ---")
                    print(t.replace('\n', ' '))
except Exception as e:
    print(f"Error occurred: {e}")
