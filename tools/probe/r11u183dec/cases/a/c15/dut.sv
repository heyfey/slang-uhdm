package p;
class e; endclass
class c;
  extern task t();
endclass
task c::t();
   bit m[e];
   int idx;
   idx = 1;
endtask
endpackage
module top; endmodule
