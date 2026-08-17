
package p;
  localparam int NP = 4;
endpackage
module m(input logic [3:0][1:0] i_data, output logic [1:0] o_result);

  function automatic bit [4-1:0][15:0] f1(int n);
    bit [4-1:0][15:0] list; int list_index; bit [15:0] current_n; bit [15:0] half_n;
    list='0; list_index=0; current_n=16'(n);
    while (current_n>0) begin
      half_n=current_n/2;
      if ((current_n>4)&&(half_n<=4)) list[list_index]=half_n;
      else if (current_n>=4) list[list_index]=4;
      else list[list_index]=current_n;
      current_n-=list[list_index]; list_index+=1;
    end
    return list;
  endfunction
  function automatic bit [4-1:0][15:0] f2(bit [4-1:0][15:0] a2);
    bit [4-1:0][15:0] list;
    for (int i=0;i<4;++i) list[i]=a2[i]+16'(i);
    return list;
  endfunction
  function automatic bit [4-1:0][15:0] g2(bit [4-1:0][15:0] b2);
    bit [4-1:0][15:0] list;
    for (int i=0;i<4;++i) list[i]=b2[i]+16'd7;
    return list;
  endfunction
  function automatic int f3(bit [4-1:0][15:0] a3);
    int next_n; next_n=0;
    for (int i=0;i<4;++i) next_n+=((a3[i]!=0)?1:0);
    return next_n;
  endfunction

  localparam bit [3:0][15:0] P1 = f1(p::NP);
  localparam bit [3:0][15:0] P2 = f2(P1);
  localparam int             P3 = f3(P2);
  logic [P3-1:0][1:0] next_data;
  always_comb begin for (int i=0;i<P3;++i) next_data[i]=i_data[0]; end
  always_comb o_result = next_data[0];
endmodule
