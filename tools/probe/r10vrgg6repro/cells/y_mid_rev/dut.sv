module m(input logic [1:0] i_data, output logic [1:0] o_result);

  function automatic bit [3:0][15:0] f1(int n);
    bit [3:0][15:0] list; int li; bit [15:0] cn; bit [15:0] hn;
    list='0; li=0; cn=16'(n);
    while (cn>0) begin
      hn=cn/2;
      if ((cn>4)&&(hn<=4)) list[li]=hn; else if (cn>=4) list[li]=4; else list[li]=cn;
      cn-=list[li]; li+=1;
    end
    return list;
  endfunction
  function automatic bit [3:0][15:0] f2(bit [3:0][15:0] a2);
    bit [3:0][15:0] list; for (int i=0;i<4;++i) list[i]=a2[i]+16'(i); return list;
  endfunction
  function automatic bit [3:0][15:0] g2(bit [3:0][15:0] b2);
    bit [3:0][15:0] list; for (int i=0;i<4;++i) list[i]=b2[i]+16'd7; return list;
  endfunction
  function automatic bit [3:0][15:0] h2(bit [3:0][15:0] c2);
    bit [3:0][15:0] list; for (int i=0;i<4;++i) list[i]=c2[i]+16'd3; return list;
  endfunction
  function automatic int f3(bit [3:0][15:0] a3);
    int nn; nn=0; for (int i=0;i<4;++i) nn+=((a3[i]!=0)?1:0); return nn;
  endfunction
  function automatic int k2(bit [3:0][15:0] x1, bit [3:0][15:0] x2);
    return int'(x1[0]) + int'(x2[0]);
  endfunction

  localparam bit [3:0][15:0] P1 = f1(4);
  localparam bit [3:0][15:0] PC = h2(P1);
  localparam bit [3:0][15:0] PB = g2(P1);
  localparam bit [3:0][15:0] PA = f2(P1);
  localparam int D1 = f3(PA);
  localparam int D2 = f3(PB);
  localparam int D3 = f3(PC);
  logic [D1+D2+D3-1:0] q;
  always_comb o_result = i_data;
endmodule
