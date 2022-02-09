# Filesystem benchmarking

The test layout 200 files of 1g each. Block size - 8k (the most common for databases).
Random scenarios makes random io with random files. Sequential scenarios makes sequental
io.

Scenarios are in fio directory. Every scenario has some tests. Every test increases count
of threads.

plot.sh helps draw results.

Running:

```
sudo make DIR=/filesystem-mount-point/test-dir-name
./plot.sh 001-randread-bs8KB.json result.hml
```
