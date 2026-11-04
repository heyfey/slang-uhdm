// § hpSelRoute157
class item; int idx; int lo; logic [15:0] v; endclass
class user;
  item o; int arr[8]; logic [3:0] y; int z;
  function new(); o = new; endfunction
  function void run();
    z = arr[o.idx];
    y = o.v[o.lo +: 4];
    arr[o.idx] = o.lo;
    z = (o.idx > 2) ? o.lo : arr[o.lo];
  endfunction
endclass
module top; user u; initial begin u = new; u.run(); end endmodule
