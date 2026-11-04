// break: uninstantiated program namesake holding a class, a task, a function
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
program innermod ();
  class C; int v; function new(); v = 3; endfunction endclass
  function automatic int twice(int k); return 2*k; endfunction
  task automatic t1(output int r); r = twice(4); endtask
  int res;
  initial begin C c; c = new; t1(res); end
endprogram
