a = "string OUT_FILES [100] = '{"
out_files = ['./pythond3s/outputofdes_{}.txt'.format(i) for i in range(100)]
out_files = str(out_files)[1:-1].replace("'",'"')
a += out_files + '};'

print (a)