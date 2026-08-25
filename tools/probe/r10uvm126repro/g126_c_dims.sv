// r10uvm126 grid C - DIMENSION KIND.  string / real / byte / chandle elements
// under 1-D, 2-D, 3-D fixed, dynamic, queue, associative and MIXED dimensions,
// all inside ONE class task body (the head's own home), plus a second class
// whose task repeats the 1-D cells with different sizes so a per-site vs
// per-declaration sharing question can be asked.
package pk_charlie126;

  class Dims126;
    task walk();
      string  d1s126 [4];
      string  d2s126 [3][2];
      string  d3s126 [2][2][2];
      string  dqs126 [$];
      string  dds126 [];
      string  das126 [int];
      string  dms126 [2][];
      real    d1r126 [5];
      real    d2r126 [2][3];
      real    dqr126 [$];
      real    ddr126 [];
      real    dar126 [string];
      byte    d1b126 [6];
      byte    d2b126 [4][4];
      byte    dqb126 [$];
      byte    ddb126 [];
      byte    dab126 [int];
      chandle d1h126 [7];
      chandle dqh126 [$];
      chandle ddh126 [];
      d1s126[0] = "a"; d2s126[1][0] = "b"; d3s126[0][1][0] = "c";
      dqs126.push_back("d"); dds126 = new[2]; das126[3] = "e";
      dms126[1] = new[2];
      d1r126[1] = 1.0; d2r126[0][1] = 2.0;
      dqr126.push_back(3.0); ddr126 = new[1]; dar126["k"] = 4.0;
      d1b126[2] = 8'd1; d2b126[1][1] = 8'd2;
      dqb126.push_back(8'd3); ddb126 = new[3]; dab126[9] = 8'd4;
      d1h126[3] = null; dqh126.push_back(null); ddh126 = new[1];
    endtask
  endclass

  class Echo126;
    task stride();
      string  e1s126 [9];
      real    e1r126 [8];
      byte    e1b126 [7];
      chandle e1h126 [6];
      e1s126[8] = "z"; e1r126[7] = 9.0; e1b126[6] = 8'd9; e1h126[5] = null;
    endtask
  endclass

endpackage
