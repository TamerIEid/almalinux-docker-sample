import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

stock_file = Path(os.environ.get("STOCK_FILE", "/var/lib/inventory/stock.json"))


class InventoryHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/stock":
            self.send_error(404)
            return
        try:
            stock = stock_file.read_bytes()
        except OSError:
            self.send_error(503, "Stock file unavailable")
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(stock)))
        self.end_headers()
        self.wfile.write(stock)


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), InventoryHandler).serve_forever()
