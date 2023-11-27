from core import app

if __name__ == '__main__':
    from routes import *
    app.run(debug=True)

    # https://dev.to/curiouspaul1/creating-modularized-flask-apps-with-blueprints-19nc
