import sys; sys.stdout.reconfigure(encoding="utf-8")
out = []

# header
out.append("# -*- coding: utf-8 -*-")
out.append("import asyncio, time, sys, os, json, urllib.request")
out.append("")
out.append("G=chr(27)+chr(91)+chr(52)+chr(50)+chr(109)")
out.append("R=chr(27)+chr(91)+chr(57)+chr(49)+chr(109)")
out.append("Y=chr(27)+chr(91)+chr(57)+chr(51)+chr(109)")
out.append("C=chr(27)+chr(91)+chr(57)+chr(54)+chr(109)")
out.append("B=chr(27)+chr(91)+chr(49)+chr(109)")
out.append("E=chr(27)+chr(91)+chr(48)+chr(109)")
out.append("def ok(s):return G+s+E")
out.append("def bad(s):return R+s+E")
out.append("def warn(s):return Y+s+E")
out.append("def hdr(s):return B+C+s+E")
out.append("")
out.append("print(hdr(chr(61)*60))")
out.append("print(hdr(\"  ReActLab Agent Benchmark\"))")
out.append("print(hdr(chr(61)*60))")
out.append("print(f\"  {time.strftime(chr(37)+chr(89)+chr(45)+chr(37)+chr(109)+chr(45)+chr(37)+chr(100)+chr(32)+chr(37)+chr(72)+chr(58)+chr(37)+chr(77)+chr(58)+chr(37)+chr(83))}\")")
out.append("print()")

with open(\"eval_benchmark.py\",\"w\",encoding=\"utf-8\") as f:
    f.write(chr(10).join(out))
print(\"header written\")
