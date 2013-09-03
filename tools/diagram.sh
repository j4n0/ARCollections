python objc_dep.py ../ARCollections/sources/collections > graph.dot
dot -Tpng graph.dot > ../graph.png
rm graph.dot
