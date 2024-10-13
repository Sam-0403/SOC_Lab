// `timescale 10ps / 1ps
// (* use_dsp = "no" *)
// module fir 
// #(  parameter pADDR_WIDTH = 12,
//     parameter pDATA_WIDTH = 32,
//     parameter Tape_Num    = 11
// )
// (
//     output  wire                     awready,
//     output  wire                     wready,
//     input   wire                     awvalid,
//     input   wire [(pADDR_WIDTH-1):0] awaddr,
//     input   wire                     wvalid,
//     input   wire [(pDATA_WIDTH-1):0] wdata,
    
//     output  wire                     arready,
//     input   wire                     rready,
//     input   wire                     arvalid,
//     input   wire [(pADDR_WIDTH-1):0] araddr,
//     output  wire                     rvalid,
//     output  wire [(pDATA_WIDTH-1):0] rdata,  
      
//     input   wire                     ss_tvalid, 
//     input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
//     input   wire                     ss_tlast, 
//     output  wire                     ss_tready, 
    
//     input   wire                     sm_tready, 
//     output  wire                     sm_tvalid, 
//     output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
//     //output  wire [(pDATA_WIDTH-1):0] sm_temp,
//     output  wire                     sm_tlast, 
    
//     // bram for tap RAM
//     output  wire [3:0]               tap_WE,
//     output  wire                     tap_EN,
//     output  wire [(pDATA_WIDTH-1):0] tap_Di,
//     output  wire [(pADDR_WIDTH-1):0] tap_A, 
//     input   wire [(pDATA_WIDTH-1):0] tap_Do,

//     // bram for data RAM
//     output  wire [3:0]               data_WE,
//     output  wire                     data_EN,
//     output  wire [(pDATA_WIDTH-1):0] data_Di,
//     output  wire [(pADDR_WIDTH-1):0] data_A,
//     input   wire [(pDATA_WIDTH-1):0] data_Do,

//     input   wire                     axis_clk,
//     input   wire                     axis_rst_n
    
// );
// begin
    
    
//     reg [31:0] status;
//     reg [31:0] cnt, datalength;
    
//     reg writing, awriting; 
//     reg rr;  // pause wready
//     reg sswait; 
//     reg smset;
//     reg WaitRD;
//     reg Done;
//     reg last;
//     reg backp;
//     reg backp_delayed;
//     reg [31:0] temp, result;
//     reg init;
//     reg [5:0] readptr;
//     reg [5:0] dreadptr;
    
//     reg [(pADDR_WIDTH-1):0] awaddr_r;
//     wire [(pADDR_WIDTH-1):0] awaddr_now =   
//         (awriting && writing) ? 0 : 
//         ((awvalid && awready) ? (awaddr) : (awaddr_r));
//     wire [(pADDR_WIDTH-1):0] awaddr_write = (awvalid && awready) ? (awaddr) : (awaddr_r);

//     reg [(pDATA_WIDTH-1):0] wdata_r;
//     wire [(pDATA_WIDTH-1):0] wdata_now =    
//         (awriting && writing) ? 0 :
//         ((wvalid && wready) ? (wdata) : (wdata_r));
//     wire [(pDATA_WIDTH-1):0] wdata_write = (wvalid && wready) ? (wdata) : (wdata_r);

//     reg [(pADDR_WIDTH-1):0] araddr_r;
//     wire [(pADDR_WIDTH-1):0] araddr_now = (arvalid && arready) ? (araddr) : (araddr_r);

//     initial begin
//         readptr = 0;
//         dreadptr = Tape_Num - 1;
//         datalength = 0;
//         cnt = 0;
//         last = 0;
//         sswait = 0;
//         smset = 0;
//         rr = 0;
//         writing = 0; awriting = 0;
//         init = 1;
//         status = 32'b0;
//         status[0] = 0; // start
//         status[1] = 0; // done
//         status[2] = 1; //idle
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n ) begin 
//             awaddr_r <= 0;
//         end 
//         else if (awvalid && awready) begin
//             awaddr_r <= awaddr;
//         end 
//         else if (awriting && writing) begin
//             awaddr_r <= 0;
//         end 
//         else begin
//             awaddr_r <= awaddr_r;
//         end
//     end
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n ) begin 
//             wdata_r <= 0;
//         end 
//         else if (wvalid && wready) begin
//             wdata_r <= wdata;
//         end 
//         else if (awriting && writing) begin
//             wdata_r <= 0;
//         end 
//         else begin
//             wdata_r <= wdata_r;
//         end
//     end
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n ) begin 
//             araddr_r <= 0;
//         end 
//         else if (arvalid && arready) begin
//             araddr_r <= araddr;
//         end 
//         // else if (rvalid && rready) begin
//         //     araddr_r <= 0;
//         // end 
//         else begin
//             araddr_r <= araddr_r;
//         end
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             result <= 0;
//         end 
//         else if (Done & !smset ) begin
//             result <= temp + data_Do * tap_Do;
//         end else if (backp & sm_tvalid && sm_tready) begin
//             result <= temp;
//         end
//         else begin
//             result <= result;
//         end
        
//     end
    
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             backp <= 0;
//         end 
//         else if (sm_tvalid && sm_tready) begin
//             backp <= 0;
//         end 
//         else if (smset && readptr == 4'd10) begin
//             backp <= 1;
//         end
//         else begin
//             backp <= backp;
//         end
//     end

//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             backp_delayed <= 0;
//         end 
//         else begin
//             backp_delayed <= backp;
//         end
//     end

//     assign ss_tready = (!status[2] && !sswait && !init && !last && !backp) ? 1 : 0;
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             last <= 0;
//         end 
//         else if (status[0]) begin
//             last <= 0;
//         end 
//         else if (cnt==datalength) begin
//         // else if ((cnt==datalength) && Done) begin
//             if (sm_tvalid && !sm_tready) begin
//                 last <= (backp_delayed) ? (1) : (last);
//             end
//             else begin
//                 last <= 1;
//             end
//         end 
//         else begin
//             last <= last;
//         end
//     end
    
//         always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             WaitRD <= 0;
//         end 
//         else if (ss_tready && ss_tvalid ) begin
//             WaitRD <= 1;
//         end 
//         else begin
//             WaitRD <= 0;
//         end
        
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             Done <= 0;
//         end 
//         else if (readptr == 4'd10 && sswait) begin
//             Done <= 1;
//         end 
//         else begin
//             Done <= 0;
//         end
        
//     end
    
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             sswait <= 0;
//         end else if (ss_tready && ss_tvalid) begin
//             sswait <= 1;
//         end else if (readptr == 4'd10 && sswait) begin
//             sswait <= 0;
//         end else sswait <= sswait;
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             smset <= 0;
//         end 
//         else if (backp) begin
//             smset <= 1;       
//         end 
//         else if (sm_tvalid && sm_tready) begin
//             smset <= 0;
//         end 
//         else if (Done) begin
//             smset <= 1;
//         end 
//         else smset <= smset;
//     end
    
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             cnt <= 0;
//         end 
//         else if (status[0]) begin
//             cnt <= 0;
//         end 
//         else if (ss_tready && ss_tvalid) begin
//         // else if (ss_tready && sm_tvalid) begin
//             cnt <= cnt + 1;
//         end 
//         else cnt <= cnt;
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n)begin
//             temp <= 0;
//         end 
//         else if (WaitRD)begin
//             temp <= data_Do * tap_Do;
//         end 
//         // else if (sswait ) begin
//         else if (sswait||Done) begin
//             temp <= temp + data_Do * tap_Do ;
//         end 
//         else temp <= temp;
//     end
    
    
//     assign sm_tvalid = (smset) ? 1 : 0; //#
//     assign sm_tlast = (smset && last) ? 1 : 0;

//     assign data_Di =(init) ? 0: 
//                     (ss_tready ) ? ss_tdata : 
//                     (sswait) ? sm_tdata : 0;
                    
//     assign data_A =  (init) ? dreadptr << 2:
//                     (!status[2]) ? dreadptr<<2 : 0;

//     assign data_WE = (init) ? 4'b1111 :
//                      (ss_tready && ss_tvalid) ? 4'b1111 :
//                      (sswait) ? 4'b0 : 0;
                     
//     assign data_EN = (init) ? 1:
//                      (!status[2]) ? 1:0;
                    
//     //assign sm_temp = temp;
//     assign sm_tdata = result;

//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n )begin
//             readptr <= 0;
//         //end else if (smset && readptr == 4'd10) begin
//         //    readptr <= readptr;
//         end else if (readptr == 4'd10) begin
//             readptr <= 0;
//         end else if (((ss_tready && ss_tvalid) || sswait) && (readptr != 4'd10))begin
//             readptr <= readptr + 1;
//         end else begin
//             readptr <= readptr;
//         end
      
//     end
    
// //    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n )begin
//             dreadptr <= Tape_Num - 1;
//         end else if (status[0]) begin
//             dreadptr <= Tape_Num - 1;
//         end else if (dreadptr == 0 && init) begin
//             dreadptr <= 0; 
//         end else if (init) begin
//             dreadptr <= dreadptr - 1;
//         //end else if (smset) begin
//         //    dreadptr <= dreadptr;
//         end else if (dreadptr == 0 && (((ss_tready && ss_tvalid) || sswait ) && readptr != 4'd10)) begin
//             dreadptr <= Tape_Num - 1;
//         end else if (((ss_tready && ss_tvalid) || sswait) && readptr != 4'd10)begin
//             dreadptr <= dreadptr - 1;
//         end else begin
//             dreadptr <= dreadptr;
//         end
      
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n )begin
//             init <= 1;
//         end else if (status[0]) begin
//             init <= 1;
//         end else if (dreadptr == 0) begin
//             init <= 0;
//         end else init <= init;
//     end    
    
    
//     assign awready = (!awriting)? 1:0;
//     assign wready = (!writing)? 1:0;
    
//     wire awriting_comb = awready && awvalid && status[2];
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n) begin
//             awriting <= 0;
//         end else if (awready && awvalid && status[2]) begin
//             awriting <= 1;
//         end else if (awriting && writing ) begin
//             awriting <= 0;
//         end else begin
//             awriting <= awriting ;
//         end
//     end
    
//     wire writing_comb = wready && wvalid && status[2];
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n) begin
//             writing <= 0;
//         end else if (wready && wvalid && status[2]) begin
//             writing <= 1;
//         end else if (awriting && writing ) begin
//             writing <= 0;
//         end else begin
//             writing <= writing ;
//         end
//     end
    
    
//     // assign tap_Di = (!status[2] && !init) ? 4'b0 :
//     //                 (writing||writing_comb) ? wdata : 0;
                    
//     // assign tap_A =  (!status[2] && !init) ? readptr<<2:
//     //                 ((awriting||awriting_comb) && awaddr  >= 12'h20 ) ? awaddr -12'h20:
//     //                 (arready && arvalid ) ? araddr - 12'h20: 0; 
                    
//     // assign tap_WE = (!status[2] && !init) ? 4'b0 :
//     //                 (writing||writing_comb) ? 4'b1111 : 0;
                    
//     // assign tap_EN = (!status[2] && !init) ? 1:
//     //                 ((writing||writing_comb) && awaddr >= 12'h20) ? 1:
//     //                 (rvalid && araddr >= 12'h20) ? 1 : 0;

//     assign tap_Di = (!status[2] && !init) ? 4'b0 :
//                     (writing||writing_comb) ? wdata : 0;
                    
//     assign tap_A =  (!status[2] && !init) ? readptr<<2:
//                     ((awriting||awriting_comb) && awaddr_now  >= 12'h20 ) ? awaddr_now -12'h20:
//                     (arready && arvalid ) ? araddr_now - 12'h20: 0; 
                    
//     assign tap_WE = (!status[2] && !init) ? 4'b0 :
//                     (writing||writing_comb) ? 4'b1111 : 0;
                    
//     assign tap_EN = (!status[2] && !init) ? 1:
//                     ((writing||writing_comb) && awaddr_now >= 12'h20) ? 1:
//                     (rvalid && araddr_now >= 12'h20) ? 1 : 0;

//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n) begin
//             datalength  <= 0;
//         end 
//         else if ( awaddr_write == 12'h10 && awriting && writing) begin
//             datalength <= wdata_write;
//         end 
//         else datalength <= datalength ;
//     end
// /// status control
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if(!axis_rst_n) begin
//             status[0] <= 0; // start
//             status[2] <= 1; //idle
//         end else if (sm_tlast) begin
//             status[0] <= 0;
//             status[2] <= 1;
//         end else if (awaddr_now == 12'h0 && wvalid && awvalid && status[2]) begin
//             status[0] <= wdata[0]; // set ap_start if programme
//             status[2] <= status[2];
//         end else if (status[0]) begin
//             status[0] <= 0;
//             status[2] <= 0;
//         end else begin
//             status [0] <= status[0];
//             status [2] <= status[2];
//         end
//     end
    
//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if(!axis_rst_n) begin
//             status[1] <= 0;
//         end
//         else if (sm_tlast && sm_tvalid && sm_tready) begin
//             status[1] <= 1;          // set ap_done after last output is transferred
//         end 
//         else if (araddr_now == 12'h0 && rready  && rvalid ) begin
//             status[1] <= 0;         // reset ap_done after status being read
//         end 
//         else begin
//             status[1] <= status[1];
//         end
//     end
// /// write control done        
        
// /// read control
    

//     always@(posedge axis_clk or negedge axis_rst_n ) begin
//         if (!axis_rst_n ) begin 
//             rr <= 0;
//         end else if (arvalid && arready) begin
//             rr <= 1;
//         end else if (rvalid && rready) begin
//             rr <= 0;
//         end else begin
//             rr <= rr;
//         end
//     end

    

//     assign arready = (!rr) ? 1 :0;
//     assign rvalid = (rr) ? 1 : 0;
    
//     // assign rdata = (rvalid && araddr == 12'h0) ? status :  
//     //                (rvalid && araddr == 12'h10) ? datalength :
//     //                (rvalid && araddr >= 12'h20) ? tap_Do : 0 ;
//     assign rdata = (rvalid && araddr_now == 12'h0) ? status :  
//                    (rvalid && araddr_now == 12'h10) ? datalength :
//                    (rvalid && araddr_now >= 12'h20) ? tap_Do : 0 ;

//     // TODO
//     // Save araddr, awaddr, wdata as register 
// end
// endmodule 

module fir #(  
	parameter pADDR_WIDTH = 12,
	parameter pDATA_WIDTH = 32,
	parameter Tape_Num    = 11
)(
	output  wire                     awready,
	output  wire                     wready,
	input   wire                     awvalid,
	input   wire [(pADDR_WIDTH-1):0] awaddr,
	input   wire                     wvalid,
	input   wire [(pDATA_WIDTH-1):0] wdata,
	output  wire                     arready,
	input   wire                     rready,
	input   wire                     arvalid,
	input   wire [(pADDR_WIDTH-1):0] araddr,
	output  wire                     rvalid,
	output  wire [(pDATA_WIDTH-1):0] rdata,
	input   wire                     ss_tvalid,
	input   wire [(pDATA_WIDTH-1):0] ss_tdata,
	input   wire                     ss_tlast,
	output  wire                     ss_tready,
	input   wire                     sm_tready,
	output  wire                     sm_tvalid,
	output  wire [(pDATA_WIDTH-1):0] sm_tdata,
	output  wire                     sm_tlast,

	// bram for tap RAM
	output  wire [3:0]               tap_WE,
	output  wire                     tap_EN,
	output  wire [(pDATA_WIDTH-1):0] tap_Di,
	output  wire [(pADDR_WIDTH-1):0] tap_A,
	input   wire [(pDATA_WIDTH-1):0] tap_Do,

	// bram for data RAM
	output  wire [3:0]               data_WE,
	output  wire                     data_EN,
	output  wire [(pDATA_WIDTH-1):0] data_Di,
	output  wire [(pADDR_WIDTH-1):0] data_A,
	input   wire [(pDATA_WIDTH-1):0] data_Do,

	input   wire                     axis_clk,
	input   wire                     axis_rst_n
);

//---------------------------------------------------------------------
//        PARAMETER DECLARATION
//---------------------------------------------------------------------
localparam IDLE     = 3'd0;
localparam INIT     = 3'd1;
localparam RUN_INIT = 3'd2;
localparam RUN_TAP  = 3'd3;
localparam EXE      = 3'd4;
localparam BUFF     = 3'd5;
localparam OUTPUT   = 3'd6;
localparam DONE     = 3'd7;

localparam DATA_WIDTH = $clog2(Tape_Num);

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION && CONNECTION                            
//--------------------------------------------------------------------- 
reg  [9:0] count_r;
wire ap_start;
wire ap_done;
wire ap_idle;

reg [DATA_WIDTH-1:0] tap_ptr_r;
reg [DATA_WIDTH-1:0] tap_ptr_w;
reg [DATA_WIDTH-1:0] data_ptr_r;
reg [DATA_WIDTH-1:0] data_ptr_w;
reg [DATA_WIDTH-1:0] start_ptr_r;
wire [DATA_WIDTH-1:0] end_ptr;

wire [pDATA_WIDTH-1:0] coef;
wire [pDATA_WIDTH-1:0] data;
wire [pDATA_WIDTH-1:0] data_length;
wire                   reading_status;

wire signed [pDATA_WIDTH-1:0] mul;
reg  [pDATA_WIDTH-1:0] sum_r;

wire sm_samp;
wire en;
wire shift;
wire wait_ram;
reg is_last_r;


reg [2:0] state_r, state_w;


assign ap_done = (state_r==DONE||(state_r==OUTPUT&&(sm_samp&&count_r==(data_length[0+:10]+1))))?1'b1:1'b0;
assign ap_idle = (state_r==IDLE||state_r==DONE||(state_r==OUTPUT&&(sm_samp&&count_r==(data_length[0+:10]+1))))?1'b1:1'b0;
assign en = ((state_r==INIT&&wait_ram)||(state_r==OUTPUT&&sm_samp&&!(count_r==(data_length[0+:10]+1))))?1'b1:1'b0;
assign sm_samp = sm_tvalid & sm_tready;
assign sm_tvalid = (state_r == OUTPUT) & sm_tready;
assign sm_tdata  = sum_r;
// assign sm_tlast  = ss_tlast;
assign sm_tlast  = is_last_r;

assign mul = coef * data;
assign end_ptr = (start_ptr_r==0)?(Tape_Num-1):(start_ptr_r-1);

//---------------------------------------------------------------------
//        MODULE INSTATIATION 
//---------------------------------------------------------------------
axi_lite axi_lite_U(
	.awready(awready),
	.wready(wready),
	.awvalid(awvalid),
	.awaddr(awaddr),
	.wvalid(wvalid),
	.wdata(wdata),
	.arready(arready),
	.rready(rready),
	.arvalid(arvalid),
	.araddr(araddr),
	.rvalid(rvalid),
	.rdata(rdata),
	.tap_WE(tap_WE),
	.tap_EN(tap_EN),
	.tap_Di(tap_Di),
	.tap_A(tap_A),
	.tap_Do(tap_Do),
	.ap_start(ap_start),
	.ap_done(ap_done),
	.ap_idle(ap_idle),
	.data_length(data_length),
	.FIR_raddr(tap_ptr_r),
	.FIR_rdata(coef),
	.reading_status(reading_status),
	.axis_clk(axis_clk),
	.axis_rst_n(axis_rst_n)
);
  
axi_stream axi_stream_U(
	.ss_tvalid(ss_tvalid),
	.ss_tdata(ss_tdata),
	.ss_tlast(ss_tlast),
	.ss_tready(ss_tready),
	.data_WE(data_WE),
	.data_EN(data_EN),
	.data_Di(data_Di),
	.data_A(data_A),
	.data_Do(data_Do),
	.en(en),
	.shift(shift),
	.wait_ram(wait_ram),
	.FIR_addr(data_ptr_r),
	.FIR_data(data),
	.ap_start(ap_start),
	.ap_done(ap_done),
	.axis_clk(axis_clk),
	.axis_rst_n(axis_rst_n)
);
	  
//---------------------------------------------------------------------
//        finite state_r machine - state_r logic
//---------------------------------------------------------------------
always@(*)begin
	case(state_r)
		IDLE: begin
			if (ap_start) 
				state_w = INIT;
			else
				state_w = IDLE;
		end
		INIT: begin
			if (wait_ram) 
				state_w = RUN_INIT;
			else 
				state_w = INIT;
		end
		RUN_INIT: begin
			if (shift) 
				state_w = RUN_TAP;
			else 
				state_w = RUN_INIT;
		end
		// TODO: Overlap RUN_TAP with EXE
		RUN_TAP: begin
			state_w = EXE;
		end
		EXE: begin
			if (count_r <= Tape_Num + 1) begin
				if (data_ptr_r == (Tape_Num-1)) 
					// state_w = OUTPUT;
					state_w = BUFF;
				else 
					// state_w = RUN_TAP;
					state_w = EXE;
			end 
			else begin
				if (tap_ptr_r == 0) 
					// state_w = OUTPUT;
					state_w = BUFF;
				else 
					// state_w = RUN_TAP;
					state_w = EXE;
			end
		end
		BUFF: begin
			state_w = OUTPUT;
		end
		OUTPUT: begin
			if (sm_samp) begin
				if (count_r == (data_length[0+:10]+1)) 
					state_w = DONE;
				else 
					state_w = RUN_INIT;
			end 
			else begin
				state_w = 
					(count_r>=(Tape_Num+1)) ? 
					((data_ptr_r==end_ptr)?(OUTPUT):(EXE)) : 
					((data_ptr_r==0)?(OUTPUT):(EXE));
			end
		end
		DONE: begin
			// if (ap_start) 
			//   state_w = INIT;
			if (ap_done & reading_status) 
				state_w = IDLE;
			else 
				state_w = DONE;
		end
		default: begin
			state_w = IDLE;
		end
	endcase
end
  
//---------------------------------------------------------------------
//        finite state_r machine - output logic
//---------------------------------------------------------------------
always@(posedge axis_clk or negedge axis_rst_n) begin
	if(!axis_rst_n) begin
		is_last_r <= 0;
	end 
	else begin
		is_last_r <= 
			(ap_idle)?
			0:
			((ss_tlast & ss_tready) ? 1 : is_last_r);
	end
end

always@(posedge axis_clk or negedge axis_rst_n) begin
	if(!axis_rst_n) begin
		state_r    <= IDLE;
		tap_ptr_r  <= 0;
		data_ptr_r <= 0;
	end 
	else begin
		state_r    <= state_w;
		tap_ptr_r  <= tap_ptr_w;
		data_ptr_r <= data_ptr_w;
	end
end
  
always@(posedge axis_clk or negedge axis_rst_n) begin
	if(!axis_rst_n) begin
		sum_r       <= 0;
		count_r     <= 2;
		start_ptr_r <= 2;
	end 
	else begin
	  	case(state_r)
			IDLE: begin
				sum_r       <= 0;
				count_r     <= 2;
				start_ptr_r <= 2;
			end
			INIT: begin
				sum_r       <= 0;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			RUN_INIT: begin
				sum_r       <= 0;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			// TODO: Overlap RUN_TAP with EXE
			RUN_TAP: begin
				sum_r       <= sum_r;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			EXE: begin
				sum_r       <= sum_r + mul;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			BUFF: begin
				sum_r       <= sum_r + mul;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			OUTPUT: begin
				if (sm_samp) begin
					if (start_ptr_r == (Tape_Num-1)) begin
						start_ptr_r <= 0;
					end 
					else begin
						start_ptr_r <= start_ptr_r + 1;
					end
					count_r       <= count_r + 1;
					sum_r         <= 0;
					// sum_r         <= (state_r==EXE)?(sum_r + mul):(0);
				end 
				else begin
					count_r     <= count_r;
					sum_r       <= sum_r;
					// sum_r       <= (state_r==EXE)?(sum_r + mul):(sum_r);
					start_ptr_r <= start_ptr_r;
				end
			end
			DONE: begin
				sum_r       <= 0;
				count_r     <= count_r;
				start_ptr_r <= start_ptr_r;
			end
			default: begin
				sum_r       <= 0;
				count_r     <= 2;
				start_ptr_r <= 2;
			end
	  	endcase
	end
end
  
always@(*)begin
	case(state_r)
		IDLE: begin
			data_ptr_w = 0;
			tap_ptr_w  = 0;
		end
		INIT: begin
			data_ptr_w = 0;
			tap_ptr_w  = 0;
		end
		RUN_INIT: begin
			data_ptr_w = data_ptr_r;
			tap_ptr_w  = tap_ptr_r;
		end
		// TODO: Overlap RUN_TAP with EXE
		RUN_TAP: begin
			// tap_ptr_w  = tap_ptr_r;
			// data_ptr_w = data_ptr_r;
			if (data_ptr_r == (Tape_Num-1)) begin
				data_ptr_w = 0;
			end 
			else begin
				data_ptr_w = data_ptr_r + 1;  
			end 

			if (tap_ptr_r == 0) begin  
				tap_ptr_w = Tape_Num-1;  
			end 
			else begin  
				tap_ptr_w = tap_ptr_r-1;  
			end  
		end
		EXE: begin
			if (data_ptr_r == (Tape_Num-1)) begin
				data_ptr_w = 0;
			end 
			else begin
				data_ptr_w = data_ptr_r + 1;  
			end 

			if (tap_ptr_r == 0) begin  
				tap_ptr_w = Tape_Num-1;  
			end 
			else begin  
				tap_ptr_w = tap_ptr_r-1;  
			end  
		end
		BUFF: begin
			tap_ptr_w  = tap_ptr_r;
			data_ptr_w = data_ptr_r;
		end
		OUTPUT: begin
			if (sm_samp) begin
				if (count_r < (Tape_Num+1)) begin
					tap_ptr_w = (count_r - 1);
				end 
				else begin
					tap_ptr_w = (Tape_Num - 1);
				end

				if (count_r >= (Tape_Num+1)) begin
					data_ptr_w = start_ptr_r;
				end 
				else begin
					data_ptr_w = 0;
				end
			end 
			else begin
				tap_ptr_w  = tap_ptr_r;
				data_ptr_w = data_ptr_r;
			end
		end
		DONE: begin
			tap_ptr_w  = 0;
			data_ptr_w = 0;
		end
		default: begin
			tap_ptr_w  = 0;
			data_ptr_w = 0;
		end
	endcase
end
  
endmodule
