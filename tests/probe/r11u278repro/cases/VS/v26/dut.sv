// § trailIdxVarSelNamesByPath278
class c;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [1:0][3:0] m;
  function logic get(); return this.q.f[m[1][2]]; endfunction
endclass
module top(output logic o); c h = new; assign o = 1'b0; endmodule
