****************************
OSGI Configuration List
****************************

===================
Introduction
===================

What is this?
---------------

A command line tool to list up OSGi configuration parameters on your AEM instance.

Thanks to `AEM OSGi Config Details`_, we can see the parameter descriptions of CQ 5.5 - AEM 6.2. This tool generates a similar list.

.. _AEM OSGi Config Details: http://www.aemstuff.com/osgi.html

===================
Setup
===================

Requirements
----------------

- Ruby 2.x

Installation
----------------

1. Extract osgi_config_list directory to under your covenient directory on your PC.
2. (Mac/Unix users only) Give execution permission to the script.

  ::

  $ chmod +x bin/generate.sh


===================
Usage
===================


Generate the list
---------------------------------------------

Windows users::

  > bin\generate.bat -s localhost -p 4502

Mac users::

  $ bin/generate.sh -s localhost -p 4502

The above command generates the list in HTML, config_list.html, under "out" directory.
You can see the full path to config_list.html in the console.
Browse out/config_list.html to your favorite browser to see the result.


.. EOF

