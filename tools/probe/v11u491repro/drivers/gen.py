import os
R='/tmp/wt_v11u491/tools/probe/v11u491repro/cases'
def mk(g,n,law,src):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n%s'%(law,src.lstrip('\n')))
def simple(g,n,law,param,body,inst,topdecl=''):
    mk(g,n,law,f"""
module m #({param}) (output logic [7:0] o);
{body}
endmodule
module top; {topdecl}logic [7:0] o;
{inst}
endmodule
""")
T='bitNegTypedOperandSize491'
i=0
# typed defaults
for ty,df in [('logic [15:0]',"12'd4"),('logic [7:0]',"8'b0000_0100"),('logic [7:0]',"6'b000100"),('bit [3:0]',"8'd3"),
              ('logic [7:0]',"'d4"),('logic [7:0]',"'b100"),('logic [7:0]',"'o4"),('logic [7:0]',"4'o4"),
              ('int unsigned',"8'd4"),('shortint',"4'd4"),('byte',"4'd4"),('longint',"4'd4"),('integer',"16'b0100"),
              ('logic signed [15:0]',"4'd4"),('bit signed [7:0]',"4'b0100"),('int',"4'd4"),('int',"'d4"),
              ('logic [63:0]',"4'd4"),('logic',"1'b1"),('bit',"1'b0"),('logic [7:0]',"8'D4"),('logic [7:0]',"4'B0100"),
              ('logic [0:7]',"4'd4"),('logic [7:0]',"(4'd4)"),('reg [7:0]',"4'd4"),('logic [7:0]',"4'd0"),('logic [31:0]',"4'd4")]:
    i+=1
    simple('VT','vt%02d'%i,T,f'parameter {ty} A = {df}','localparam B = ~A; assign o = B;','m u(o);')
# typed with actuals
for ty,act in [('logic [7:0]',"8'd20"),('logic [3:0]',"8'd20"),('int',"4'd5"),('logic signed [7:0]',"4'd5"),('logic signed [7:0]',"'d5"),
               ('int',"5"),('logic [7:0]',"'h5"),('logic [7:0]',"4'o5"),('integer',"'b101"),('logic [7:0]',"(4'd5)"),('logic [7:0]',"4'D5"),
               ('longint',"40'd5"),('logic [7:0]',"0")]:
    i+=1
    simple('VT','vt%02d'%i,T,f'parameter {ty} A = 8\'d1','localparam B = ~A; assign o = B;',f'm #(.A({act})) u(o);')
# typed: B read as operand, B read in other contexts
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; assign o = B + 1;','m u(o);')
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; logic [7:0] q; always_comb q = B; assign o = q;','m u(o);')
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; localparam C = B; assign o = C;','m u(o);')
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; assign o = B;','m u(o); m #(.A(8\'d9)) u2();')
# ordered override, typed
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; assign o = B;',"m #(4'd6) u(o);")
# child instance (nested)
i+=1; mk('VT','vt%02d'%i,T,"""
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module mid(output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
""")
i+=1; mk('VT','vt%02d'%i,T,"""
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m u(o[g]); end
endmodule
""")
i+=1; mk('VT','vt%02d'%i,T,"""
interface ifc #(parameter bit [7:0] A = 4'd4); localparam B = ~A; logic [7:0] o; assign o = B; endinterface
module top; ifc u(); endmodule
""")
i+=1; mk('VT','vt%02d'%i,T,"""
module m #(parameter bit [7:0] A = 4'd4) (output logic [7:0] o);
parameter B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
# typedef'd types
i+=1; mk('VT','vt%02d'%i,T,"""
typedef logic [7:0] b8_t;
module m #(parameter b8_t A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
i+=1; mk('VT','vt%02d'%i,T,"""
typedef logic signed [7:0] s8_t;
module m #(parameter s8_t A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
i+=1; mk('VT','vt%02d'%i,T,"""
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter s_t A = 4'd4) (output logic [7:0] o);
localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
# defparam on typed A
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~A; assign o = B;',"m u(o); defparam u.A = 4'd6;")
# A in package? not instance. B ~A in generate block
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'if (1) begin : g localparam B = ~A; assign o = B; end','m u(o);')
# B = ~(A)
i+=1; simple('VT','vt%02d'%i,T,"parameter bit [7:0] A = 4'd4",'localparam B = ~(A); assign o = B;','m u(o);')
# body localparam A (not port param)
i+=1; mk('VT','vt%02d'%i,T,"""
module m (output logic [7:0] o);
localparam bit [7:0] A = 4'd4; localparam B = ~A; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); endmodule
""")

# unsized based actual forms
U='ovUnsizedBasedActualForm491'
j=0
for pd,act in [("parameter int A = 4","'h5"),("parameter int A = 4","'hff"),("parameter logic [7:0] A = 4","'hFFF"),("parameter logic [7:0] A = 4","'d300"),
               ("parameter logic [7:0] A = 4","'b1_0_1"),("parameter A = 4","'hAb"),("parameter A = 4'd3","'hAb"),("parameter A = 4","'D5"),
               ("parameter A = 4","'B101"),("parameter A = 4","'O17"),("parameter logic signed [7:0] A = 4","'h7F"),("parameter logic signed [7:0] A = 4","'hFF"),
               ("parameter integer A = 4","'h0"),("parameter A = 4","'h0"),("parameter A = 4","'b0"),("parameter longint A = 4","'hFFFF_FFFF"),
               ("parameter A = 4","'hFFFFFFFF"),("parameter A = 4","'d2147483648"),("parameter bit [3:0] A = 4","'b11111"),
               ("parameter A = 8'hF","'h5"),("parameter A = 4","('h5)"),("parameter shortint A = 4","'hFFFFF"),("parameter A = \"ab\"","'h5"),("parameter real A = 1.0","'h5")]:
    j+=1
    simple('VA','va%02d'%j,U,pd,'assign o = A;',f'm #(.A({act})) u(o);')
for pd,act,body in [("parameter A = 4","'h5",'localparam B = A + 1; assign o = B;'),("parameter A = 4","'h5",'assign o = A + 1;'),
                    ("parameter A = 4","'h5",'logic [7:0] q; always_comb q = A; assign o = q;'),("parameter A = 4","'h5",'wire [7:0] w = A; assign o = w;'),
                    ("parameter int A = 4","'h5",'localparam B = A; assign o = B;'),("parameter A = 4","'h5",'initial $display(A); assign o = 0;'),
                    ("parameter A = 4","'h5",'if (A == 5) begin : g assign o = 1; end else begin : h assign o = 0; end'),
                    ("parameter A = 4","'h5",'logic [A:0] q; assign o = q;')]:
    j+=1
    simple('VA','va%02d'%j,U,pd,body,f'm #(.A({act})) u(o);')
# contexts
j+=1; simple('VA','va%02d'%j,U,"parameter A = 4",'assign o = A;',"m #('h5) u(o);")
j+=1; simple('VA','va%02d'%j,U,"parameter A = 4",'assign o = A;',"m #(.A('h5)) u(o); m #(.A('h6)) u2();")
j+=1; mk('VA','va%02d'%j,U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid(output logic [7:0] o); m #(.A('h5)) u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
""")
j+=1; mk('VA','va%02d'%j,U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m #(.A('h5)) u(o[g]); end
endmodule
""")
j+=1; mk('VA','va%02d'%j,U,"""
interface ifc #(parameter A = 4); logic [7:0] o; assign o = A; endinterface
module top; ifc #(.A('h5)) u(); endmodule
""")
j+=1; simple('VA','va%02d'%j,U,"parameter A = 4",'assign o = A;',"m #(.A('h5)) u(o); defparam u.A = 'h7;")
j+=1; mk('VA','va%02d'%j,U,"""
module m #(parameter A = 4, parameter B = A) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m #(.B('h5)) u(o); endmodule
""")
j+=1; mk('VA','va%02d'%j,U,"""
module m #(parameter type T = int, parameter T A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.T(logic [7:0]), .A('h5)) u(o); endmodule
""")
j+=1; mk('VA','va%02d'%j,U,"""
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid #(parameter P = 1) (output logic [7:0] o); m #(.A('h5)) u(o); endmodule
module top; logic [7:0] o; mid #(.P(2)) x(o); endmodule
""")

# sized more bases
S='ovSizedActualMoreBases491'
k=0
for pd,act in [("parameter A = 4'd15","4'b0010"),("parameter A = 4'd15","4'sb0010"),("parameter A = 4'd15","4'Sb1010"),("parameter A = 4'd15","8'sd200"),
               ("parameter A = 4'd15","4'shf"),("parameter A = 4'd15","4'shF"),("parameter A = 4'd15","8'hab"),("parameter A = 4'd15","8'Hab"),
               ("parameter A = 4'd15","12'o7777"),("parameter A = 4'd15","40'b1"),("parameter A = 4'd15","64'o1"),("parameter A = 4'd15","4'b1x10"),
               ("parameter A = 8'hF","4'b1010"),("parameter A = 4'b1","4'b1010"),("parameter A = 4'd15","1'b1"),("parameter A = 4'd15","16'b1010_1010_1010_1010"),
               ("parameter A = 4'd15","17'b1_0101_0101_0101_0101"),("parameter A = 4'd15","4'SD3"),("parameter A = 4'd15","32'sd2147483648"),("parameter A = 4'd15","(4'b1010)"),
               ("parameter A = 4'd15","4'sb1111"),("parameter A = 4'd15","8'o377")]:
    k+=1
    simple('VO','vo%02d'%k,S,pd,'assign o = A;',f'm #(.A({act})) u(o);')
for pd,act,body in [("parameter A = 4'd15","4'b1010",'localparam B = A + 1; assign o = B;'),("parameter A = 4'd15","4'sb1010",'assign o = A + 1;'),
                    ("parameter A = 4'd15","4'b1010",'logic [7:0] q; always_comb q = A; assign o = q;'),("parameter A = 4'd15","4'sd3",'localparam B = ~A; assign o = B;'),
                    ("parameter A = 4'd15","4'b1010",'logic [A:0] q; assign o = q;'),("parameter A = 4'd15","4'sb1010",'localparam B = A; assign o = B;')]:
    k+=1
    simple('VO','vo%02d'%k,S,pd,body,f'm #(.A({act})) u(o);')
k+=1; mk('VO','vo%02d'%k,S,"""
module m #(parameter A = 4'd15) (output logic [7:0] o); assign o = A; endmodule
module mid(output logic [7:0] o); m #(.A(4'b1010)) u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
""")
k+=1; simple('VO','vo%02d'%k,S,"parameter A = 4'd15",'assign o = A;',"m #(4'b1010) u(o); m #(4'o3) u2();")
k+=1; mk('VO','vo%02d'%k,S,"""
interface ifc #(parameter A = 4'd15); logic [7:0] o; assign o = A; endinterface
module top; ifc #(.A(4'b1010)) u(); endmodule
""")

# bare name
N='bitNegBareNameActual491'
l=0
for topd,pd in [("localparam int P = 5; ","parameter A = 4"),("localparam integer P = 5; ","parameter A = 4"),("localparam longint P = 5; ","parameter A = 4"),
                ("localparam logic signed [7:0] P = 5; ","parameter A = 4"),("localparam bit [3:0] P = 5; ","parameter A = 4"),("localparam P = 4'd5; ","parameter A = 4"),
                ("localparam P = 'd5; ","parameter A = 4"),("localparam Q = 6; localparam P = Q; ","parameter A = 4"),("localparam Q = 3'd6; localparam P = Q; ","parameter A = 4"),
                ("localparam P = 5; ","parameter int A = 4"),("localparam P = 5; ","parameter logic [3:0] A = 4"),("localparam P = 5; ","parameter A = 4'd4"),
                ("localparam P = 64'd5; ","parameter A = 4"),("localparam P = 5; ","parameter A = 4"),("localparam P = 3 + 2; ","parameter A = 4"),
                ("localparam P = 0; ","parameter A = 4"),("localparam [7:0] P = 300; ","parameter A = 4"),("parameter P = 5; ","parameter A = 4")]:
    l+=1
    simple('VN','vn%02d'%l,N,pd,'localparam B = ~A; assign o = B;','m #(.A(P)) u(o);',topdecl=topd)
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module mid #(parameter P = 5) (output logic [7:0] o); m #(.A(P)) u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module mid #(parameter P = 5) (output logic [7:0] o); m #(.A(P)) u(o); endmodule
module top; logic [7:0] o; mid #(.P(7)) x(o); endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m #(.A(P)) u(o[g]); end
endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; logic [7:0] o;
if (1) begin : g localparam P = 5; m #(.A(P)) u(o); end
endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
package pk; localparam P = 5; endpackage
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; import pk::*; logic [7:0] o; m #(.A(P)) u(o); endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o; m #(.A(P)) u(o); defparam u.A = 6; endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o; m #(P) u(o); endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module mid #(parameter P = 5) (output logic [7:0] o); m #(.A(P)) u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.P = 9; endmodule
""")
l+=1; mk('VN','vn%02d'%l,N,"""
module m #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule
module top; localparam P = 5; logic [7:0] o; m #(.A(P)) u(o); m #(.A(P)) u2(); endmodule
""")

# beside defparam
D='unboundedDepBesideDefparam491'
q=0
for pd,body,dp in [("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd0, parameter X = 1","localparam B = A - 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A * 4'd2; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = $clog2(A) + 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; localparam C = B + 4'd1; assign o = C;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam [7:0] B = A + 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; assign o = B + 1;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = {A, 4'd1}; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A ? A + 4'd1 : 4'd0; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; assign o = B;","defparam u.X = 2; defparam u.A = 4'd14;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; assign o = B;","defparam u.X = 2;"),  # placeholder replaced below
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A << 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = -A; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; localparam C = X + B; assign o = C;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = 4'd15 + 4'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 32'hFFFF_FFFF, parameter X = 1","localparam B = A + 32'd1; assign o = B;","defparam u.X = 2;"),
                   ("parameter A = 4'd15, parameter X = 1","localparam B = A + 4'd1; wire [B:0] w; assign o = w;","defparam u.X = 2;")]:
    q+=1
    simple('VB','vb%02d'%q,D,pd,body,'m u(o); '+dp)
mk('VB','vb11',D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = A + 4'd1; assign o = B;
endmodule
module top; logic [7:0] o; m #(.A(4'd14)) u(o); defparam u.X = 2; endmodule
""")
q+=1; mk('VB','vb%02d'%q,D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = A + 4'd1; assign o = B;
endmodule
module mid(output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.u.X = 2; endmodule
""")
q+=1; mk('VB','vb%02d'%q,D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = A + 4'd1; assign o = B;
endmodule
module top; logic [7:0] o; m u(o); m u2(); defparam u.X = 2; endmodule
""")
q+=1; mk('VB','vb%02d'%q,D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
localparam B = A + 4'd1; assign o = B;
endmodule
module top; logic [7:0] o; m u(o);
endmodule
module dp; defparam top.u.X = 2; endmodule
""")
q+=1; mk('VB','vb%02d'%q,D,"""
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o);
if (1) begin : g localparam B = A + 4'd1; assign o = B; end
endmodule
module top; logic [7:0] o; m u(o); defparam u.X = 2; endmodule
""")

# sub size
Z='unboundedSubSize64_491'
z=0
for pd,body,inst in [("parameter A = 4'd3","localparam B = A - 4'd1; assign o = B;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; localparam C = B; assign o = C + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; localparam C = B + 4'd1; assign o = C + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = (A - 4'd1) + 4'd2; assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A + 4'd2 - 4'd1; assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A > 4'd1 ? A - 4'd1 : 4'd0; assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 1; assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = 4'd3 - 4'd1; assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; wire [B:0] w; assign o = w;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; logic [7:0] q; always_comb q = B; assign o = q;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; assign o = B + 1;","m #(.A(4'd7)) u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; assign o = B + 1;","m u(o); defparam u.A = 4'd7;"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; localparam [7:0] C = B; assign o = C + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; parameter C = B * 4'd2; assign o = C + 1;","m u(o);"),
                     ("parameter A = 4'd3, parameter B = A - 4'd1","assign o = B + 1;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; localparam C = ~B; assign o = C;","m u(o);"),
                     ("parameter A = 4'd3","localparam B = A - 4'd1; localparam C = B - B; assign o = C + 1;","m u(o);"),
                     ("parameter A = 8'd3","localparam B = A - 4'd1; assign o = B + 1;","m u(o);")]:
    z+=1
    simple('VS','vs%02d'%z,Z,pd,body,inst)
z+=1; mk('VS','vs%02d'%z,Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); localparam B = A - 4'd1; assign o = B + 1; endmodule
module mid(output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
""")
z+=1; mk('VS','vs%02d'%z,Z,"""
interface ifc #(parameter A = 4'd3); localparam B = A - 4'd1; logic [7:0] o; assign o = B + 1; endinterface
module top; ifc u(); endmodule
""")
z+=1; mk('VS','vs%02d'%z,Z,"""
module m #(parameter A = 4'd3) (output logic [7:0] o); if (1) begin : g localparam B = A - 4'd1; assign o = B + 1; end endmodule
module top; logic [7:0] o; m u(o); endmodule
""")
z+=1; mk('VS','vs%02d'%z,Z,"""
package pk; localparam A = 4'd3; localparam B = A - 4'd1; endpackage
module top; import pk::*; logic [7:0] o; assign o = B + 1; endmodule
""")
