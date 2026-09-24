// r10uvm99 arm a7: exotic first members and set shapes.
package theta99_pkg;
  localparam int PA = 1;
  localparam int PB = 4;
endpackage
module iota99;
  import theta99_pkg::*;
  int aq99 [$];
  int nn99, mm99;
  logic [7:0] bv99;
  string s99;
  function automatic bit h1(int zv);
    return zv inside {[PA:PB]};
  endfunction
  function automatic bit h2(int zv);
    return zv inside {nn99 + mm99, 3};
  endfunction
  function automatic bit h3(int zv);
    return zv inside {[nn99*2 : mm99+1]};
  endfunction
  function automatic bit h4(logic [7:0] zv);
    return zv inside {8'b1010_10?0};
  endfunction
  function automatic bit h5(int zv);
    return zv inside {aq99[0], [2:3]};
  endfunction
  function automatic bit h6(string zv);
    return zv inside {"aa", "bb"};
  endfunction
  function automatic bit h7(int zv);
    return zv inside {aq99};
  endfunction
  function automatic bit h8(int zv);
    return (zv inside {[1:2]}) && (zv inside {[5:6]});
  endfunction
endmodule
