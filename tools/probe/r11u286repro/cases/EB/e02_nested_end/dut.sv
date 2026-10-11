// § escBlockNameSpanTrailSpace286 — nested escaped blocks with end labels, in a child instance, a task and a function
module kid(input logic [3:0] d, output logic [3:0] r);
  always_comb begin : \outer@1 
    begin : \inner+2 
      r = d;
    end : \inner+2 
  end : \outer@1 
  task automatic t();
    begin : \tb@1 
    end
  endtask
  function automatic int f();
    begin : \fb@1 
      return 1;
    end
  endfunction
endmodule
module top(input logic [3:0] d, output logic [3:0] r);
  kid u(.d(d), .r(r));
endmodule
