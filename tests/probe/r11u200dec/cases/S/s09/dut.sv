module s09;
  if (1) begin : g1
    function automatic int  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g2
    function automatic int signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g3
    function automatic int unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g4
    function automatic integer  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g5
    function automatic integer signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g6
    function automatic integer unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g7
    function automatic shortint  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g8
    function automatic shortint signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g9
    function automatic shortint unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g10
    function automatic longint  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g11
    function automatic longint signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g12
    function automatic longint unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g13
    function automatic byte  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g14
    function automatic byte signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g15
    function automatic byte unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g16
    function automatic bit  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g17
    function automatic bit signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g18
    function automatic bit unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g19
    function automatic logic  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g20
    function automatic logic signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g21
    function automatic logic unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g22
    function automatic reg  f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g23
    function automatic reg signed f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
  if (1) begin : g24
    function automatic reg unsigned f;
      input integer x;
      f = x;
    endfunction
    logic [127:0] c = f(-1);
  end
endmodule
