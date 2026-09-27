package p;
typedef bit [3:0] k_t;
class c;
  extern task t();
endclass
task c::t();
   int n;
   int m[k_t];
   foreach (m[k]) n = n + 1;
endtask
endpackage
module top; endmodule
