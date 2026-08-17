
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
  function automatic int f3(bit [3:0][15:0] a3);
    int nn; nn=0; for (int i=0;i<4;++i) nn+=((a3[i]!=0)?1:0); return nn;
  endfunction
  localparam bit [3:0][15:0] P1 = f1(4);
  localparam bit [3:0][15:0] P2 = f2(P1);

  for (genvar gi = 0; gi < f3(P2); gi++) begin : g
    logic [1:0] q;
  end
  always_comb o_result = i_data;
endmodule
