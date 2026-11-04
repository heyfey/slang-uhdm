// § parenCallCallee479
module top(output int z); int q[$]; string s; initial begin z = (q.size()) + (s.len()); end endmodule
