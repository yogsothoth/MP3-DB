MP3::DB
======

scan, index, transform and publish MP3 collections in MongoDB

MP3::DB is a simple tool to scan, index and import ID3 tag information from MP3 collections into a MongoDB, transform 
this data and export it for use with knightlab's TimeLine.

This module relies on the amazing Dist::Zilla for building, testing, etc.

MP3::DB comes with a rather complete documentation, see perldoc for usage.

About the code
--------------

This module has been written as an exercice to explore interacting with MongoDB from Perl and playing with TimeLine.

The object model has been kept really simple and naïve for two reasons:
    1. The tool already relies on App::Cmd, adding Moose would just have slowed startup even more for no obvious benefit
    2. MP3::DB has been written while exploring the domain at the same time; keeping the object model simple proved much 
    helpful

Likewise, some shortcuts have been taken in the code, since the main objective was to get a working tool quickly out 
the door and not necessarily to do the right thing in every case.

It is very likely MP3::DB will evolve into a general purpose data preparation tool for TimeLine-like libraries. 
This means I might update the code here whenever I spot something really wrong or broken, but the main effort will now
be directed toward the new, generalised module.
