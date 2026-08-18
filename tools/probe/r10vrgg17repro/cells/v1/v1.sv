// vrgg17 v1 — INDEX-SHAPE axis, far beyond the implementer's g1.
interface sif; logic [31:0] value; endinterface
module sink (input logic [3:0] d); endmodule
module top;
  localparam int LP = 3;
  parameter  int P  = 2;
  sif arr[20]();
  for (genvar i = 0; i < 2; i++) begin : g
    sink u_v1  (.d(arr[LP+i].value[0+:4]));        // localparam + genvar
    sink u_v2  (.d(arr[10-i].value[0+:4]));        // minus on the spine
    sink u_v3  (.d(arr[(8*i)/2+1].value[0+:4]));   // divide on the spine
    sink u_v4  (.d(arr[i%3+4].value[0+:4]));       // MODULO -> must abstain
    sink u_v5  (.d(arr[2**i+1].value[0+:4]));      // POWER  -> must abstain
    sink u_v6  (.d(arr[8+(-i)].value[0+:4]));      // unary minus
    sink u_v7  (.d(arr[3'd2+i].value[0+:4]));      // BASED literal -> abstain?
    sink u_v8  (.d(arr[$clog2(4)+i].value[0+:4])); // $clog2 -> abstain?
    sink u_v9  (.d(arr[(i==0)?1:2].value[0+:4]));  // ternary -> abstain?
    sink u_v10 (.d(arr[i^1].value[0+:4]));         // XOR -> abstain?
    sink u_v11 (.d(arr[LP*P+i].value[0+:4]));      // param*param + genvar
    sink u_v12 (.d(arr[i+i].value[0+:4]));         // genvar twice
    sink u_v13 (.d(arr[6+7*i].value[P+:4]));       // ips BASE is a bare PARAM
    sink u_v14 (.d(arr[6+7*i].value[i+:4]));       // ips BASE is a bare GENVAR
    sink u_v15 (.d(arr[6+7*i].value[2*i+1+:4]));   // ips BASE arithmetic, ct7
  end
endmodule
