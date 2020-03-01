<!DOCTYPE html>
<html lang="en">
        <!-- What are you peeking at? Yes, that's it, HTML5 and not a single line of JS. http://motherfuckingwebsite.com/ -->
        <head>
                <meta charset="utf-8">
                <title>{{.Doc.title}}</title>
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
                <meta name="description" content="{{.Doc.description}}">
                <link rel="stylesheet" href="/style.css">

                <style>
                    @media only screen and (max-width: 670px) {
                        aside {
                            display: none;
                        }
                    }
                </style>
        </head>
        <body>
                <h1><a href="/">fox.cpp</a> / {{.Doc.title}}</h1>
                <main>
                    <aside>
                        {{.Include "templates/sidebar.tpl"}}
                    </aside>
                    <contents>
                        <article>
                            {{.Doc.body}}
                        </article>
                    </contents>
                </main>
                <hr>
                <footer>
                    {{.Include "templates/footer.tpl"}}
                </footer>
        </body>
</html>

