//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Игорь Коноваленко on 07.07.2022.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
    @State private var timer = Timer.publish(every: 0.01,
                                             on: .main, in: .common).autoconnect()
    @StateObject var album = album_data()
    @State var animatedValue: CGFloat = 55
    @State var maxWidth = UIScreen.main.bounds.width / 2.2
    @State var time: Float = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(album.title)
                    HStack(spacing: 10) {
                        Text(album.artist)
                            .font(.caption)
                        Text(album.type)
                            .font(.caption)
                    }
                }
                Spacer(minLength: 0)
                Button(action: {}) {
                    Image(systemName: "suit.heart.fill")
                        .foregroundColor(.red)
                        .frame(width: 45, height: 45)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                Button(action: {}) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.black)
                        .frame(width: 45, height: 45)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(.leading, 10)
            }
            .padding()
            Spacer(minLength: 0)
            if album.artwork.count != 0 {
                Image(uiImage: UIImage(data: album.artwork)!)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(15)
            }
            ZStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: animatedValue / 2,
                               height: animatedValue / 2)
                }
                .frame(width: animatedValue, height: animatedValue)
                Button(action: play) {
                    Image(systemName: album.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.black)
                        .frame(width: 55, height: 55)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
            }
            .frame(width: maxWidth, height: maxWidth)
            .padding(.top, 30)
            // Tracking
            
            Slider(value: Binding(get: { time }, set: { (newValue) in
                time = newValue
                audioPlayer.currentTime = Double(time) * audioPlayer.duration
                audioPlayer.play()
            }))
            .padding()
            Spacer(minLength: 0)
        }
        .onReceive(timer) { _ in
            if audioPlayer.isPlaying {
                audioPlayer.updateMeters()
                album.isPlaying = true
                // updating slider
                time = Float(audioPlayer.currentTime / audioPlayer.duration)
                // get anime
                startAnimation()
            } else {
                album.isPlaying = false
            }
        }
        .onAppear(perform: getAudioData)
    }
    
    func play() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
    func getAudioData() {
        audioPlayer.isMeteringEnabled = true
        let asset = AVAsset(url: audioPlayer.url!)
        asset.metadata.forEach { meta in
            switch(meta.commonKey?.rawValue) {
            case "artwork": album.artwork = meta.value == nil ? UIImage(named: "any sample")!.pngData()! : meta.value as! Data
                
            case "artist": album.artist = meta.value == nil ? "" : meta.value as! String
            case "type": album.type = meta.value == nil ? "" : meta.value as! String
            case "title": album.title = meta.value == nil ? "" : meta.value as! String
            default: ()
            }
            
        }
    }
    
    func startAnimation() {
        var power: Float = 0
        for i in 0..<audioPlayer.numberOfChannels {
            power += audioPlayer.averagePower(forChannel: i)
        }
        let value = max(0, power + 55)
        let animated = CGFloat(value) * (maxWidth / 55)
        withAnimation(.linear(duration: 0.01)) {
            self.animatedValue = animated + 55
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class album_data: ObservableObject {
    @Published var isPlaying = false
    @Published var title = ""
    @Published var artist = ""
    @Published var artwork = Data(count: 0)
    @Published var type = ""
}


let url = Bundle.main.path(forResource: "audio",
                           ofType: "mp3")
