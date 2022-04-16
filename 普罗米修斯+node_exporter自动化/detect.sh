#!/bin/bash
./lan-live.sh | grep -i up | awk '{print $1}' > livehosts 

cat > prometheus-hosts <<END
#!/bin/bash
END
n=0
for i in `cat livehosts | sort -n`
do
if [ "$n" == 0 ]
then
echo "prometheus=$i" >> prometheus-hosts 
else
echo "node$n=$i" >> prometheus-hosts
fi
n=`expr $n + 1`
done
