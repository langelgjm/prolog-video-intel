# Video Intelligence WIP

Some tools for assessing various video intelligence platforms.

## Thumbnail Generation Endpoint

Running `make develop` and visiting

    http://127.0.0.1:8000/thumbnails?path=path/to/video.mp4&start=30.0&end=35.0

will display a montage of thumbnails from the chosen video, spaced at 1 second intervals, between the start and end parameters (offsets in seconds).

## JSON -> HTML Conversion

A Prolog webserver that accepts POST requests of JSON data, and translates them into an HTML representation.

* JSON objects are represented by HTML unordered lists
    * Object keys appear in _italics_
    * Object values appear as an indented unordered list item
* JSON lists are represented by HTML ordered lists
* Any object value or list item that is a string beginning with `http` will be represented as a link.

### Examples

    [1, 2, 3]

<ol>
<li>1</li>
<li>2</li>
<li>3</li>
</ol>

    {"a": 1, "b": 2, "c": 3}

<ul>
<li><i>a</i>
<ul>
<li>1</li>
</ul>
</li>
<li><i>b</i>
<ul>
<li>2</li>
</ul>
</li>
<li><i>c</i>
<ul>
<li>3</li>
</ul>
</li>
</ul>

    ["a", ["b", ["c"]]]

<ol>
<li>a</li>
<li>

<ol>
<li>b</li>
<li>

<ol>
<li>c</li>
</ol>

</li>
</ol>

</li>
</ol>

    {"a": {"b": {"c": "d"}}}

<ul>
<li><i>a</i>
<ul>
<li><i>b</i>
<ul>
<li><i>c</i>
<ul>
<li>d</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>

    [{"a": "b"}]

<ol>
<li>
<ul>
<li><i>a</i>
<ul>
<li>b</li>
</ul>
</li>
</ul>
</li>
</ol>

    {"a": ["b"]}

<ul>
<li><i>a</i>
<ul>
<li>

<ol>
<li>b</li>
</ol>

</li>
</ul>
</li>
</ul>

    {"a": [1, {"a": 1}]}

<ul>
<li><i>a</i>
<ul>
<li>

<ol>
<li>1</li>
<li>
<ul>
<li><i>a</i>
<ul>
<li>1</li>
</ul>
</li>
</ul>
</li>
</ol>

</li>
</ul>
</li>
</ul>

    [1, {"a": [1]}]

<ol>
<li>1</li>
<li>
<ul>
<li><i>a</i>
<ul>
<li>

<ol>
<li>1</li>
</ol>

</li>
</ul>
</li>
</ul>
</li>
</ol>

    ["http://list_item_link", {"key": "http://object_value_item_link"}]

<ol>
<li><a href="http://list_item_link">http://list_item_link</a></li>
<li>
<ul>
<li><i>key</i>
<ul>
<li><a href="http://object_value_item_link">http://object_value_item_link</a></li>
</ul>
</li>
</ul>
</li>
</ol>