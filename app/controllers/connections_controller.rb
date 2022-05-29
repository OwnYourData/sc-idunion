class ConnectionsController < ApplicationController
    def qr
        did = ""
        @configItems = Store.where(schema_dri: CONFIG_ITEM_DRI)
        @configItems.each do |i|
            begin
                if JSON.parse(i.item)["key"] == "connect_qr"
                    did = JSON.parse(i.item)["value"]
                end
            rescue
            end
        end unless @configItems.nil?
        qrcode = RQRCode::QRCode.new(did)
        png = qrcode.as_png(
          bit_depth: 1,
          border_modules: 4,
          color_mode: ChunkyPNG::COLOR_GRAYSCALE,
          color: "black",
          file: nil,
          fill: "white",
          module_px_size: 6,
          resize_exactly_to: false,
          resize_gte_to: false,
          size: 360
        )        
        output = "<html><head><title>Scan QR</title>"
        output +="<style>span { position: absolute;top: 50%;left: 50%;width: 360;height: 360;margin-top: -180px;margin-left: -180px; }</style>"
        output +="</head><body><span>"
        output +='<img src="data:image/png;base64,' + Base64.strict_encode64(png.to_s) + '"><br>'
        output += did.to_s
        output +="</span></body></html>" 
        render html: output.html_safe, 
               status: 200
    end
end