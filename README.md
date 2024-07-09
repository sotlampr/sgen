# A static site generator (?) in scheme


```bash
cat << EOF > index.ss
(html
  (head
    (style "*{ color: blue; }")
    (script "console.log('yo');")
    (body
        (:include "content")
        (div (id "link") (:include-and-link "link" "See also")))))
EOF

cat << EOF > content.ss
(div (id "content")
 (h1 "Hello")
 (p "This is a paragraph" (br) "and here is another line"))
EOF

cat << EOF > link.ss
(html
        (body (h1 "Another page") (p "Another text")))
EOF
scheme --script sgen.ss
```

Outputs (pretty'd):
```html
<html>
	<head>
		<style>*{ color: blue; }</style>
		<script>console.log('yo');</script>
	</head>
	<body>
		<div id="content">
			<h1>Hello</h1>
			<p>This is a paragraph
				<br>and here is another line
				</p>
			</div>
			<div id="link">
				<a href="/link.html">See also</a>
			</div>
		</body>
	</html>
```
