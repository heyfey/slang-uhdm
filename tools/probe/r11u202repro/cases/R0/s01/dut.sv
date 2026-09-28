// § tfSigningSpanFollowsCompilePath200
package p;
  class c;
    function shortint unsigned g(input byte unsigned b, input logic signed [3:0] l);
      return b + l;
    endfunction
  endclass
endpackage
module s01;
  task t(input bit unsigned a, output int signed o); o = a; endtask
  function automatic longint unsigned f;
    input reg signed [2:0] r;
    f = r;
  endfunction
endmodule
