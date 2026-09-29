// § ndaSizeFoldReach219 — an array of a typedef'd unpacked array and a packed array of packed arrays through a typedef, one and two arguments
module dut (output logic [7:0] o1, o2, o3, o4, o5);
  typedef logic [3:0] arr_t [5];
  typedef logic [2:0][1:0] pk_t;
  arr_t a [2];
  pk_t  p [6];
  wire [7:0] w1 = $size(a);
  wire [7:0] w2 = $size(a, 2);
  wire [7:0] w3 = $size(a, 3);
  wire [7:0] w4 = $size(p, 2);
  wire [7:0] w5 = $size(p, 3);
  assign o1 = w1; assign o2 = w2; assign o3 = w3; assign o4 = w4; assign o5 = w5;
endmodule
