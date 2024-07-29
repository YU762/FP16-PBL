`ifdef ENABLE_FPU
  input  wire                                 h_ex2_d_s,
  input  wire [ 8:0]                          h_ex2_d_exp,
  input  wire [25+`PEXT:0]                    h_ex2_d_frac, //������
  input  wire                                 h_ex2_d_inf,
  input  wire                                 h_ex2_d_nan,
  input  wire                                 l_ex2_d_s,
  input  wire [ 8:0]                          l_ex2_d_exp,
  input  wire [25+`PEXT:0]                    l_ex2_d_frac, //������
  input  wire                                 l_ex2_d_inf,
  input  wire                                 l_ex2_d_nan,
`endif

`ifdef ENABLE_FPU
  wire [31:0]                   h_fpd;
  wire [31:0]                   l_fpd;
//wire [`REG_DATA_BITS-1:0]     fpd = (`conf_op2==`OP_WSWAP)?{l_fpd, h_fpd}:{h_fpd, l_fpd};
  wire [`REG_DATA_BITS-1:0]     fpd = {h_fpd, l_fpd};

  fpu3 fpu3h /* normalize, no register slice, just combination logic */
  (
    .ex2_d_s     (h_ex2_d_s          ),
    .ex2_d_exp   (h_ex2_d_exp        ),
    .ex2_d_frac  (h_ex2_d_frac       ),
    .ex2_d_inf   (h_ex2_d_inf        ),
    .ex2_d_nan   (h_ex2_d_nan        ),
    .f           (h_fpd              )
  );
  fpu3 fpu3l
  (
    .ex2_d_s     (l_ex2_d_s          ),
    .ex2_d_exp   (l_ex2_d_exp        ),
    .ex2_d_frac  (l_ex2_d_frac       ),
    .ex2_d_inf   (l_ex2_d_inf        ),
    .ex2_d_nan   (l_ex2_d_nan        ),
    .f           (l_fpd              )
  );
`else
  wire [`REG_DATA_BITS-1:0]     fpd = {(`REG_DATA_BITS){1'b0}};
`endif

`ifdef ENABLE_FPU
module fpu3
(
  input  wire                                 ex2_d_s,
  input  wire [ 8:0]                          ex2_d_exp,
  input  wire [25+`PEXT:0]                    ex2_d_frac, //������
  input  wire                                 ex2_d_inf,
  input  wire                                 ex2_d_nan,
  output wire [31:0]                          f
);
  function [31:0] normalizer;
    input               ex1_d_s;
    input [8:0]         ex1_d_exp;
    input [25+`PEXT:0]  ex1_d_frac; //������
    input               ex1_d_inf;
    input               ex1_d_nan;

    reg [5:0]           ex2_w_lzc; //������
    reg                 ex2_d_s;
    reg [7:0]           ex2_d_exp;
    reg [22:0]          ex2_d_frac;

    begin
      /* normalize */
      ex2_w_lzc = (ex1_d_frac[`PEXT+25]) ? 6'd62:
		  (ex1_d_frac[`PEXT+24]) ? 6'd63:
                  (ex1_d_frac[`PEXT+23]) ? 6'd0:
                  (ex1_d_frac[`PEXT+22]) ? 6'd1:
                  (ex1_d_frac[`PEXT+21]) ? 6'd2:
                  (ex1_d_frac[`PEXT+20]) ? 6'd3:
                  (ex1_d_frac[`PEXT+19]) ? 6'd4:
                  (ex1_d_frac[`PEXT+18]) ? 6'd5:
                  (ex1_d_frac[`PEXT+17]) ? 6'd6:
                  (ex1_d_frac[`PEXT+16]) ? 6'd7:
                  (ex1_d_frac[`PEXT+15]) ? 6'd8:
                  (ex1_d_frac[`PEXT+14]) ? 6'd9:
                  (ex1_d_frac[`PEXT+13]) ? 6'd10:
                  (ex1_d_frac[`PEXT+12]) ? 6'd11:
                  (ex1_d_frac[`PEXT+11]) ? 6'd12:
                  (ex1_d_frac[`PEXT+10]) ? 6'd13:
                  (ex1_d_frac[`PEXT+ 9]) ? 6'd14:
                  (ex1_d_frac[`PEXT+ 8]) ? 6'd15:
                  (ex1_d_frac[`PEXT+ 7]) ? 6'd16:
                  (ex1_d_frac[`PEXT+ 6]) ? 6'd17:
                  (ex1_d_frac[`PEXT+ 5]) ? 6'd18:
                  (ex1_d_frac[`PEXT+ 4]) ? 6'd19:
                  (ex1_d_frac[`PEXT+ 3]) ? 6'd20:
                  (ex1_d_frac[`PEXT+ 2]) ? 6'd21:
                  (ex1_d_frac[`PEXT+ 1]) ? 6'd22:
                  (ex1_d_frac[`PEXT+ 0]) ? 6'd23:
`ifdef PEXT_01
		  (ex1_d_frac[`PEXT- 1]) ?(6'd23+ 1):
`endif
`ifdef PEXT_02
		  (ex1_d_frac[`PEXT- 2]) ?(6'd23+ 2):
`endif
`ifdef PEXT_03
		  (ex1_d_frac[`PEXT- 3]) ?(6'd23+ 3):
`endif
`ifdef PEXT_04
		  (ex1_d_frac[`PEXT- 4]) ?(6'd23+ 4):
`endif
`ifdef PEXT_05
		  (ex1_d_frac[`PEXT- 5]) ?(6'd23+ 5):
`endif
`ifdef PEXT_06
		  (ex1_d_frac[`PEXT- 6]) ?(6'd23+ 6):
`endif
`ifdef PEXT_07
		  (ex1_d_frac[`PEXT- 7]) ?(6'd23+ 7):
`endif
`ifdef PEXT_08
		  (ex1_d_frac[`PEXT- 8]) ?(6'd23+ 8):
`endif
`ifdef PEXT_09
		  (ex1_d_frac[`PEXT- 9]) ?(6'd23+ 9):
`endif
`ifdef PEXT_10
		  (ex1_d_frac[`PEXT-10]) ?(6'd23+10):
`endif
`ifdef PEXT_11
		  (ex1_d_frac[`PEXT-11]) ?(6'd23+11):
`endif
`ifdef PEXT_12
		  (ex1_d_frac[`PEXT-12]) ?(6'd23+12):
`endif
`ifdef PEXT_13
		  (ex1_d_frac[`PEXT-13]) ?(6'd23+13):
`endif
`ifdef PEXT_14
		  (ex1_d_frac[`PEXT-14]) ?(6'd23+14):
`endif
`ifdef PEXT_15
		  (ex1_d_frac[`PEXT-15]) ?(6'd23+15):
`endif
`ifdef PEXT_16
		  (ex1_d_frac[`PEXT-16]) ?(6'd23+16):
`endif
`ifdef PEXT_17
		  (ex1_d_frac[`PEXT-17]) ?(6'd23+17):
`endif
`ifdef PEXT_18
		  (ex1_d_frac[`PEXT-18]) ?(6'd23+18):
`endif
`ifdef PEXT_19
		  (ex1_d_frac[`PEXT-19]) ?(6'd23+19):
`endif
`ifdef PEXT_20
		  (ex1_d_frac[`PEXT-20]) ?(6'd23+20):
`endif
`ifdef PEXT_21
		  (ex1_d_frac[`PEXT-21]) ?(6'd23+21):
`endif
`ifdef PEXT_22
		  (ex1_d_frac[`PEXT-22]) ?(6'd23+22):
`endif
`ifdef PEXT_23
		  (ex1_d_frac[`PEXT-23]) ?(6'd23+23):
`endif
                                          (6'd24+`PEXT);

      //   $display("ex1:%x %x %x\n", ex1_d_s, ex1_d_exp, ex1_d_frac);

      if (ex1_d_nan) begin
        ex2_d_s    = 1'b1;
        ex2_d_frac = 23'h400000;
        ex2_d_exp  = 8'hff;
      end
      else if (ex1_d_inf) begin
        ex2_d_s    = ex1_d_s;
        ex2_d_frac = 23'h000000;
        ex2_d_exp  = 8'hff;
      end
      else if (ex2_w_lzc == 6'd62) begin //������
        if (ex1_d_exp >= 253) begin
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = 23'h000000;
          ex2_d_exp  = 8'hff;
        end
        else begin
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = ex1_d_frac>>(2+`PEXT); //������
          ex2_d_exp  = ex1_d_exp[7:0] + 8'h2;
        end
      end
      else if (ex2_w_lzc == 6'd63) begin //������
        if (ex1_d_exp >= 254) begin
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = 23'h000000;
          ex2_d_exp  = 8'hff;
        end
        else begin
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = ex1_d_frac>>(1+`PEXT); //������
          ex2_d_exp  = ex1_d_exp[7:0] + 8'h1;
        end
      end
      else if (ex2_w_lzc <= (6'd23+`PEXT)) begin //������
        if (ex1_d_exp >= ex2_w_lzc + 255) begin
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = 23'h000000;
          ex2_d_exp  = 8'hff;
        end
        else if (ex1_d_exp <= ex2_w_lzc) begin /* subnormal num */
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = (ex1_d_frac<<ex1_d_exp)>>`PEXT; //������
          ex2_d_exp  = 8'h00;
        end
        else begin /* normalized num */
          ex2_d_s    = ex1_d_s;
          ex2_d_frac = (ex1_d_frac<<ex2_w_lzc)>>`PEXT; //������
          ex2_d_exp  = ex1_d_exp - {2'd0,ex2_w_lzc};   //������
        end
      end
      else begin /* zero */
        ex2_d_s    = 1'b0;
        ex2_d_frac = 23'h000000;
        ex2_d_exp  = 8'h00;
      end
      normalizer = {ex2_d_s, ex2_d_exp, ex2_d_frac};
    end
  endfunction
  assign f = normalizer( ex2_d_s, ex2_d_exp, ex2_d_frac, ex2_d_inf, ex2_d_nan);
endmodule
`endif
