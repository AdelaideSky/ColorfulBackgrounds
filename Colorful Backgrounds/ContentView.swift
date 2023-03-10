//
//  ContentView.swift
//  ColorfulBackgroundsApp
//
//  Created by Adélaïde Sky on 06/03/2023.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import GIFImage

enum exportGifState: String {
    case none
    case starting
    case calculatingFrames
    case exportFile
    case done
}
struct ContentView: View {
    @State var colorsView: ColorsView? = nil
    @State var model = "default"
    @State var models: [String] = ["default"]
    @State var colors: [SwiftUI.Color] = []
    
    @State var gif: GIFImage? = nil
    @State var gifFrames: [NSImage]? = nil
    
    @State var gifPopout: Bool = false
    @State var textPopout: Bool = false
    
    @State var titleText: String = ""
    @State var subtitleText: String = ""
    
    @State var gifExportProgress: Double = 100.0
    @State var showExportSheet = false
    @State var gifExportState: exportGifState = .none
    
    @AppStorage("fr.adesky.colorfulBackgrounds.roundedCorners") var roundedCorners: Bool = true
    @AppStorage("fr.adesky.colorfulBackgrounds.height") var height: Int = 532
    @AppStorage("fr.adesky.colorfulBackgrounds.width") var width: Int = 1600
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSpeed") var gifSpeed: Double = 0.005
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSize") var gifSize: Double = 0.7
    
    var body: some View {
        VStack {
            if colorsView != nil {
                if gif != nil {
                    ZStack {
                        colorsView
                            .frame(width: CGFloat(width), height: CGFloat(height))
                            .cornerRadius(roundedCorners ? 20 : 0)
                            .clipped()
                        gif
                            .frame(width: CGFloat(Double(width)*gifSize), height: CGFloat(Double(height)*gifSize))
                    }
                    
                } else {
                    ZStack {
                        colorsView
                            .frame(width: CGFloat(width), height: CGFloat(height))
                            .cornerRadius(roundedCorners ? 20 : 0)
                            .clipped()
                        if titleText != "" {
                            VStack {
                                Text(titleText)
                                    .font(.system(size: subtitleText != "" ? max(Double(height)/5, Double(height)/5) : max(Double(height)/3, Double(height)/3)))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                if subtitleText != "" {
                                    Text(subtitleText)
                                        .font(.system(size: 25))
                                        .multilineTextAlignment(.center)
                                }
                            }.padding()
                        }
                    }.frame(width: CGFloat(width), height: CGFloat(height))
                        .cornerRadius(roundedCorners ? 20 : 0)
                        .clipped()
                }
                
                
            }
        }.dropDestination(for: Data.self) { items, location in
            guard let item = items.first else { return false }
            gif = GIFImage(source: .static(data: item), animate: true, loop: true)
            gifFrames = item.gifFrames()
            return true
        }
        .sheet(isPresented: $showExportSheet) {
            VStack {
                Group {
                    switch gifExportState {
                    case .none:
                        EmptyView()
                    case .starting:
                        ProgressView("Starting...")
                    case .calculatingFrames:
                        Text("dfsdfdf")
                        ProgressView("Encoding frames…", value: gifExportProgress, total: 100)
                    case .exportFile:
                        ProgressView("Exporting file...")
                    case .done:
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .padding(40)
                            Text("Done !")
                            Text("Your Gif has been exported !")
                        }
                    }
                }.padding()
            }.frame(width: 400, height: 200)

           
        }
            .toolbar {
                if gif != nil {
                    ToolbarItem() {
                        Button("Gif settings") {
                            gifPopout.toggle()
                        }.popover(isPresented: $gifPopout) {
                            VStack {
                                Form {
                                    Section("Values") {
                                        Slider(value: $gifSpeed, in: 0.0001...0.1, label: {
                                            Label("Frame time", systemImage: "circle")
                                                .labelStyle(.titleOnly)
                                                .frame(width: 70, alignment: .leading)
                                        }).frame(width: 250)
                                            .controlSize(.small)
                                        Slider(value: $gifSize, in: 0.1...1, label: {
                                            Label("Gif size", systemImage: "circle")
                                                .labelStyle(.titleOnly)
                                                .frame(width: 70, alignment: .leading)
                                        }).frame(width: 250)
                                            .controlSize(.small)
                                        Button("Delete Gif") {
                                            gif = nil
                                            gifFrames = nil
                                            gifPopout.toggle()
                                        }
                                    }.toggleStyle(.switch)
                                        .formStyle(.grouped)
                                    
                                }.toggleStyle(.switch)
                                    .formStyle(.grouped)
                            }.frame(width: 300, height: 170)
                        }
                    }
                } else {
                    ToolbarItem() {
                        Button("Text settings") {
                            textPopout.toggle()
                        }.popover(isPresented: $textPopout) {
                            VStack {
                                Form {
                                    Section("Values") {
                                        TextField("Title", text: $titleText)
                                            .controlSize(.large)
                                        
                                    }.toggleStyle(.switch)
                                        .formStyle(.grouped)
                                    Section("Subtitle") {
                                        TextEditor(text: $subtitleText)
                                            .controlSize(.large)
                                            .backgroundStyle(.clear)
//                                        TextField("Subtitle", text: $subtitleText)
//                                            .controlSize(.large)
                                        Button("Clear texts") {
                                            titleText = ""
                                            subtitleText = ""
                                            gifPopout.toggle()
                                        }
                                    }.toggleStyle(.switch)
                                        .formStyle(.grouped)
                                }.toggleStyle(.switch)
                                    .formStyle(.grouped)
                            }.frame(width: 300, height: 220)
                        }
                    }
                }
                
                ToolbarItemGroup() {
                    
                    Toggle("Rounded Corners", isOn: $roundedCorners)
                    Picker("Model", selection: $model) {
                        ForEach(models, id:\.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    TextField("Width", value: $width, formatter: NumberFormatter())
                        .controlSize(.large)
                        .padding(8)
                        .frame(width: 60)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.clear)
                            .background(Color.black.opacity(0.2).cornerRadius(8)))
                        .textFieldStyle(PlainTextFieldStyle())
                    TextField("Height", value: $height, formatter: NumberFormatter())
                        .controlSize(.large)
                        .padding(8)
                        .frame(width: 60)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.clear)
                            .background(Color.black.opacity(0.2).cornerRadius(8)))
                        .textFieldStyle(PlainTextFieldStyle())
                    Button((gifFrames?.count ?? 0) > 1 ? "Copy GIF" : "Copy render") {
                        if gif != nil && gifFrames != nil && (gifFrames?.count ?? 0) > 1 {
                            Task {
                                gifExportProgress = 0.0
                                showExportSheet.toggle()
                                gifExportState = .starting
                                let renderer = ImageRenderer(content: {
                                    ZStack {
                                        colorsView
                                            .frame(width: CGFloat(width), height: CGFloat(height))
                                            .cornerRadius(roundedCorners ? 20 : 0)
                                            .clipped()
                                    }
                                }())
                                renderer.scale = 1.0
                                // make sure and use the correct display scale for this device
                                if let nsImage = renderer.nsImage {
                                    DispatchQueue.global().async {
                                        var frames: [CGImage] = []
                                        gifExportState = .calculatingFrames
                                        print("calcframe")
                                        for frame in gifFrames! {
                                            do {
                                                let image = try overlayImage(background: nsImage, overlay: frame, overlaySizeRatio: gifSize)
                                                frames.append(image)
                                                let pasteboard = NSPasteboard.general
                                                pasteboard.clearContents()
        //                                        pasteboard.writeObjects([frame])
                                                print("add \(Double(100/gifFrames!.count))")
                                                gifExportProgress += Double(100/gifFrames!.count)
                                                print(gifExportState.rawValue)
                                            } catch {
                                                print(error)
                                            }
                                            
                                        }
                                        gifExportState = .exportFile
                                        do {
                                            let exportPath: URL = getDocumentsDirectory().appendingPathComponent("ColorfulBackgrounds-GIF_Export.gif")
                                            animatedGif(from: frames, to: exportPath, speed: gifSpeed)
                                            let pasteboard = NSPasteboard.general
                                            pasteboard.clearContents()
                                            pasteboard.setString(exportPath.path(), forType: .fileURL)
                                            gifExportState = .done
                                            sleep(1)
                                            showExportSheet.toggle()
                                            gifExportState = .none
                                        } catch {print(error)}
        //                                let encodedGif = try! gif.encoded()
                                        
                                    }
                                    
                                    
                                } else {
                                    print("Error rendering image")
                                }
                            }
                        } else {
                            let renderer = ImageRenderer(content: {
                                ZStack {
                                    colorsView
                                        .frame(width: CGFloat(width), height: CGFloat(height))
                                        .cornerRadius(roundedCorners ? 20 : 0)
                                        .clipped()
                                    if gif == nil {
                                        VStack {
                                            Text(titleText)
                                                .font(.system(size: subtitleText != "" ? max(Double(height)/5, Double(height)/5) : max(Double(height)/3, Double(height)/3)))
                                                .bold()
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            if subtitleText != "" {
                                                Text(subtitleText)
                                                    .font(.system(size: 25))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                            }
                                        }.padding()
                                    } else if gifFrames != nil {
                                        Image(nsImage: gifFrames![0])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: CGFloat(Double(width)*gifSize), height: CGFloat(Double(height)*gifSize))
                                    }
                                    
                                }
                            }())
                            renderer.scale = 2.0
                            // make sure and use the correct display scale for this device
                            if let nsImage = renderer.nsImage {
                                
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.writeObjects([nsImage])
                                
                            } else {
                                print("Error rendering image")
                            }
                        }
                    }.controlSize(.large)
                        .padding(8)
                        .frame(width: 100)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.clear)
                            .background(Color.black.opacity(0.2).cornerRadius(8)))
                        .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        var tempColors: [Color] = []
                        
                        let body: [String:Any] = [
                            "model": model
                        ]
                        let url = URL(string: "http://colormind.io/api/")!
                        let request = AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default)
                            .validate()
                            .responseString() { response in
                                if response.data != nil {
                                    do {
                                        var json = try? JSON(data: response.data!)
                                        for color in json!["result"].arrayValue {
                                            
                                            let color = NSColor(red: CGFloat(color[0].floatValue), green: CGFloat(color[1].floatValue), blue: CGFloat(color[2].floatValue), alpha: CGFloat(1))
            //                                let color = Color(red: color[0].doubleValue, green: color[1].doubleValue, blue: color[2].doubleValue)
                                            tempColors.append(Color(nsColor: color))
                                        }
                                    }
                                    colors = tempColors
                                } else {
                                    print(response.error)
                                }
                            }
                    }, label: {
                        Label("Reroll", systemImage: "arrow.clockwise").labelStyle(.iconOnly)
                    }).controlSize(.large)
                }
                
            }
        
            .onAppear() {
                let modelUrl = URL(string: "http://colormind.io/list/")!
                let modelsRequest = AF.request(modelUrl, method: .get)
                    .validate()
                    .responseString() { response in
                        if response.data != nil {
                            models = []
                            do {
                                var json = try? JSON(data: response.data!)
                                for model in json!["result"].arrayValue {
                                    models.append(model.stringValue)
                                }
                            }
                        } else {
                            print(response.error)
                        }
                    }
                let body: [String:Any] = [
                    "model": model
                ]
                let url = URL(string: "http://colormind.io/api/")!
                let request = AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default)
                    .validate()
                    .responseString() { response in
                        if response.data != nil {
                            do {
                                var json = try? JSON(data: response.data!)
                                for color in json!["result"].arrayValue {
                                    
                                    let color = NSColor(red: CGFloat(color[0].floatValue), green: CGFloat(color[1].floatValue), blue: CGFloat(color[2].floatValue), alpha: CGFloat(1))
    //                                let color = Color(red: color[0].doubleValue, green: color[1].doubleValue, blue: color[2].doubleValue)
                                    colors.append(Color(nsColor: color))
                                }
                            }
                            self.colorsView = ColorsView(colors: $colors)
                        } else {
                            print(response.error)
                        }
                    }
                
            }
    }
}

struct ColorsView: View {
    
    @Binding var colors: [SwiftUI.Color]
    var body: some View {
        VStack {
            if colors.count > 4 {
                ZStack {
                    AngularGradient(colors: colors, center: .center)
                        .saturation(2)
                        .scaleEffect(1.5)
                        .blur(radius: 100)
                    Image("noise")
                        .resizable(resizingMode: .tile)
                        .scaledToFill()
                        .opacity(0.04)
                    
                }
            }
        }
        
    }
}

