// § modAggTfArgCloneFollows180 (r11u183's paramAggTdLastWriter183, measured redundant by r11u187)
module top(output logic [7:0] o);
  typedef union packed { logic [7:0] w; logic [1:0][3:0] n; } u_t;
  function automatic logic [7:0] f (u_t u); f = u.w; endfunction
  localparam u_t U = 8'h5a;
  assign o = f(U);
endmodule
