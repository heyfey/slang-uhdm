// § unpStructArrElemVar412
module top(output logic [3:0] o);
  typedef struct { logic [3:0] a; logic [3:0] b; } ms_t;
  function automatic logic [3:0] f();
    ms_t loc[2];
    loc[0].a = 4'd3;
    return loc[0].a;
  endfunction
  assign o = f();
endmodule
