set JAVA_HOME=C:\Program Files (x86)\Common Files\Oracle\Java\javapath\jre
set SAXON_HOME=C:\Program Files\Oxygen XML Editor 19\lib
set PATH=%PATH%;%SAXON_HOME%;%JAVA_HOME%;

echo Converting RNG %1 to XSD $2

java -Xmx6G -jar trang-20181222\trang.jar -I rng -O xsd %1 %2
