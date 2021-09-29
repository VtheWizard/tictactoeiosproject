//
//  ContentView.swift
//  tictactoe
//
//  Created by Ville Prittinen on 29.9.2021.
//

import SwiftUI

enum SquareStatus {
    case empty
    case player1
    case player2
}

class Square : ObservableObject {
    @Published var squareStatus : SquareStatus
    init(status : SquareStatus){
        self.squareStatus = status
    }
}

class TicTacToeModel : ObservableObject {
    @Published var squares = [Square]()
    init(){
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame(){
        for i in 0...8 {
            squares[i].squareStatus = .empty
        }
    }
    
    var gameOver : (SquareStatus, Bool){
        get {
            if winnerExists != .empty{
                return (winnerExists, true)
            }else{
                for i in 0...8{
                    if squares[i].squareStatus == .empty{
                        return(.empty, false)
                    }
                }
                return(.empty, true)
            }
        }
    }
    
    private var winnerExists:SquareStatus{
        get{
            if let check = self.checkIndexes([0, 1, 2]){
                return check
            }else if let check = self.checkIndexes([3, 4, 5]){
                return check
            }else if let check = self.checkIndexes([6, 7, 8]){
                return check
            }else if let check = self.checkIndexes([0, 3, 6]){
                return check
            }else if let check = self.checkIndexes([1, 4, 7]){
                return check
            }else if let check = self.checkIndexes([2, 5, 8]){
                return check
            }else if let check = self.checkIndexes([0, 4, 8]){
                return check
            }else if let check = self.checkIndexes([2, 4, 6]){
                return check
            }
            return .empty
        }
    }
    
    private func checkIndexes(_ indexes : [Int])-> SquareStatus?{
        var player1Counter : Int = 0
        var player2Counter : Int = 0
        for index in indexes{
            let square = squares[index]
            if square.squareStatus == .player1 {
                player1Counter+=1
            }else if square.squareStatus == .player2 {
                player2Counter+=1
            }
        }
        if player1Counter == 3 {
            return .player1
        }else if player2Counter == 3 {
            return .player2
        }
        return nil
    }
    
    private func turnAI(){
        var index = Int.random(in: 0...8)
        while turn(index: index, player: .player2) == false && gameOver.1 == false {
            index = Int.random(in: 0...8)
        }
    }
    
    func turn(index: Int, player: SquareStatus)-> Bool{
        if squares[index].squareStatus == .empty{
            squares[index].squareStatus = player
            if player == .player1{
                turnAI()
            }
            return true
        }
        return false
    }
    
}

struct SquareView : View {
    @ObservedObject var dataSource : Square
    var action:() -> Void
    var body: some View{
        Button(action:{self.action()}, label:{
                    Text(self.dataSource.squareStatus == .player1 ? " X " : self.dataSource.squareStatus == .player2 ? " O " : "     ")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue))
                        .padding(4)
        }).frame(minWidth: 60, maxWidth: 70, minHeight: 60, maxHeight: 70)
    }
}

struct ContentView: View {
    @StateObject var ticTacToeModel = TicTacToeModel()
    @State var gameOver : Bool = false
    func buttonAction(_ index : Int) {
        _ = self.ticTacToeModel.turn(index: index, player: .player1)
        self.gameOver = self.ticTacToeModel.gameOver.1
    }
    
    var body: some View {
        VStack{
            Text(" TicTacToe / ristinolla ")
                .bold()
                .foregroundColor(Color.black)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .padding(.bottom)
                .font(.title2)
            ForEach(0 ..< ticTacToeModel.squares.count / 3, content: {
                row in
                HStack {
                    ForEach(0..<3, content: {
                        column in
                        let index = row * 3 + column
                        SquareView(dataSource:ticTacToeModel.squares[index],
                                   action: {self.buttonAction(index)})
                    })
                }
            })
            Button(action:{
                    self.ticTacToeModel.resetGame()
                
            })
            {
                Text("RESET")
            }
            .frame(width: 111, height: 40)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue))
        }.alert(isPresented: self.$gameOver, content: {
            Alert(title: Text("game over"), message: Text(self.ticTacToeModel.gameOver.0 != .empty ? self.ticTacToeModel.gameOver.0 == .player1 ? "You Win!" : "AI Wins!" : "Nobody Wins" ), dismissButton: Alert.Button.destructive(Text("Ok"), action: {self.ticTacToeModel.resetGame()
            }))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
