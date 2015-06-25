import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Image;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JPanel;

import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.Hashtable;

import jpl.Term;

import javax.swing.JLabel;

import java.awt.Font;

import javax.swing.JButton;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.image.BufferedImage;

import javax.swing.UIManager;

import java.io.File;
import java.io.IOException;

import javax.swing.SwingConstants;


public class Main extends ComponentMover {
	
	private enum Player {
		None,
		Human,
		Computer
	}
	
	private enum Piece {
		Invalid,
		Empty,
		White,
		WhiteQueen,
		Black,
		BlackQueen;
	    
		public static Piece getEnum(String c) {
			if(c.equals("e"))
				return Empty;
			else if(c.equals("x"))
				return White;
			else if(c.equals("xx"))
				return WhiteQueen;
			else if(c.equals("o"))
				return Black;
			else if(c.equals("oo"))
				return BlackQueen;

			return Invalid;
		}
	}
	
	private class WinException extends Exception {
		private static final long serialVersionUID = -3863459465355736854L;

		public WinException(Player winner) {
			this.winner = winner;
		}
		
		@Override
		public String toString() {
			if(winner == Player.Human)
				return "Humano ganhou!";
			
			return "Computador ganhou!";
		}
		
		private Player winner;
	}
	
	private static int PIECE_SIZE = 50;
	private static Hashtable<Piece, ImageIcon> PIECE_IMAGE;
	private static ImageIcon BOARD_IMAGE;
	
	private JFrame frame;
	private JPanel boardPanel;
	private JLabel labelCurrentPlayer;
	
	private int previousLine;
	private int previousColumn;

	private jpl.Compound board;
	
	private Player currentPlayer;
	private JLabel lblV1;
	private JLabel labelV2;
	private JLabel labelV3;
	private JLabel labelV4;
	private JLabel labelV5;
	private JLabel labelV6;
	private JLabel labelV7;
	private JLabel labelV8;
	private JLabel labelH1;
	private JLabel labelH2;
	private JLabel labelH3;
	private JLabel labelH4;
	private JLabel labelH5;
	private JLabel labelH6;
	private JLabel labelH7;
	private JLabel labelH8;
	
	private static ImageIcon loadIcon(String path, int size) throws IOException {
		BufferedImage icon = ImageIO.read(new File(path));
		Image sicon = icon.getScaledInstance(size, size, Image.SCALE_SMOOTH);
		return new ImageIcon(sicon);
	}
	
    static
    {
    	try {
	    	PIECE_IMAGE = new Hashtable<Piece, ImageIcon>();
	    	PIECE_IMAGE.put(Piece.White, loadIcon("images/whitepawn.png", (int)(PIECE_SIZE * 0.8f)));
	    	PIECE_IMAGE.put(Piece.WhiteQueen, loadIcon("images/whitequeen.png", (int)(PIECE_SIZE * 0.8f)));
	    	PIECE_IMAGE.put(Piece.Black, loadIcon("images/blackpawn.png", (int)(PIECE_SIZE * 0.8f)));
	    	PIECE_IMAGE.put(Piece.BlackQueen, loadIcon("images/blackqueen.png", (int)(PIECE_SIZE * 0.8f)));
	    	
	    	BOARD_IMAGE = loadIcon("images/board.png", PIECE_SIZE * 8);
    	} catch(IOException e) {
    		e.printStackTrace();
    	}
    }

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Main window = new Main();
					window.frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the application.
	 * @throws Exception 
	 */
	public Main() {
	    jpl.Query loadFile = new jpl.Query("consult", new jpl.Term[] {new jpl.Atom("prolog/java.pl")});
	    if(!loadFile.hasSolution())
	    	throw new RuntimeException("Impossível carregar java.pl");
	    loadFile.rewind();
	    
	    currentPlayer = Player.Human;
		
	    initialize();
	}

	/**
	 * Initialize the contents of the frame.
	 * @throws Exception 
	 */
	private void initialize() {
		setSnapSize(new Dimension(PIECE_SIZE, PIECE_SIZE));
		
		frame = new JFrame();
		frame.getContentPane().setBackground(UIManager.getColor("menu"));
		frame.setResizable(false);
		frame.setBounds(100, 100, 670, 490);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.getContentPane().setLayout(null);
		
		labelCurrentPlayer = new JLabel("Humano");
		labelCurrentPlayer.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelCurrentPlayer.setBounds(450, 46, 204, 50);
		frame.getContentPane().add(labelCurrentPlayer);
		
		JButton btnBrancas = new JButton("Reiniciar como brancas");
		btnBrancas.setBounds(450, 107, 175, 23);
		frame.getContentPane().add(btnBrancas);
		btnBrancas.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				currentPlayer = Player.Human;
				labelCurrentPlayer.setText("Humano");
				startX();
			}
		});
		
		JButton btnPretas = new JButton("Reiniciar como pretas");
		btnPretas.setBounds(450, 141, 175, 23);
		frame.getContentPane().add(btnPretas);
		btnPretas.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					currentPlayer = Player.Computer;
					labelCurrentPlayer.setText("Computador");
					startO();
					playComputer();
				} catch (WinException e1) {
					labelCurrentPlayer.setText(e1.toString());
					e1.printStackTrace();
				} catch (Exception e1) {
					e1.printStackTrace();
				}
			}
		});
		
		boardPanel = new JPanel();
		boardPanel.setBounds(40, 46, 400, 400);
		frame.getContentPane().add(boardPanel);
		boardPanel.setBackground(UIManager.getColor("menu"));
		boardPanel.setLayout(null);
		
		lblV1 = new JLabel("1");
		lblV1.setHorizontalAlignment(SwingConstants.CENTER);
		lblV1.setFont(new Font("Tahoma", Font.PLAIN, 20));
		lblV1.setBounds(10, 46, 20, 50);
		frame.getContentPane().add(lblV1);
		
		labelV2 = new JLabel("2");
		labelV2.setBounds(10, 96, 20, 50);
		frame.getContentPane().add(labelV2);
		labelV2.setHorizontalAlignment(SwingConstants.CENTER);
		labelV2.setFont(new Font("Tahoma", Font.PLAIN, 20));
		
		labelV3 = new JLabel("3");
		labelV3.setHorizontalAlignment(SwingConstants.CENTER);
		labelV3.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV3.setBounds(10, 146, 20, 50);
		frame.getContentPane().add(labelV3);
		
		labelV4 = new JLabel("4");
		labelV4.setHorizontalAlignment(SwingConstants.CENTER);
		labelV4.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV4.setBounds(10, 196, 20, 50);
		frame.getContentPane().add(labelV4);
		
		labelV5 = new JLabel("5");
		labelV5.setHorizontalAlignment(SwingConstants.CENTER);
		labelV5.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV5.setBounds(10, 246, 20, 50);
		frame.getContentPane().add(labelV5);
		
		labelV6 = new JLabel("6");
		labelV6.setHorizontalAlignment(SwingConstants.CENTER);
		labelV6.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV6.setBounds(10, 296, 20, 50);
		frame.getContentPane().add(labelV6);
		
		labelV7 = new JLabel("7");
		labelV7.setHorizontalAlignment(SwingConstants.CENTER);
		labelV7.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV7.setBounds(10, 346, 20, 50);
		frame.getContentPane().add(labelV7);
		
		labelV8 = new JLabel("8");
		labelV8.setHorizontalAlignment(SwingConstants.CENTER);
		labelV8.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelV8.setBounds(10, 396, 20, 50);
		frame.getContentPane().add(labelV8);
		
		labelH1 = new JLabel("1");
		labelH1.setHorizontalAlignment(SwingConstants.CENTER);
		labelH1.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH1.setBounds(40, 11, 50, 30);
		frame.getContentPane().add(labelH1);
		
		labelH2 = new JLabel("2");
		labelH2.setHorizontalAlignment(SwingConstants.CENTER);
		labelH2.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH2.setBounds(90, 11, 50, 30);
		frame.getContentPane().add(labelH2);
		
		labelH3 = new JLabel("3");
		labelH3.setHorizontalAlignment(SwingConstants.CENTER);
		labelH3.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH3.setBounds(140, 11, 50, 30);
		frame.getContentPane().add(labelH3);
		
		labelH4 = new JLabel("4");
		labelH4.setHorizontalAlignment(SwingConstants.CENTER);
		labelH4.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH4.setBounds(190, 11, 50, 30);
		frame.getContentPane().add(labelH4);
		
		labelH5 = new JLabel("5");
		labelH5.setHorizontalAlignment(SwingConstants.CENTER);
		labelH5.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH5.setBounds(240, 11, 50, 30);
		frame.getContentPane().add(labelH5);
		
		labelH6 = new JLabel("6");
		labelH6.setHorizontalAlignment(SwingConstants.CENTER);
		labelH6.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH6.setBounds(290, 11, 50, 30);
		frame.getContentPane().add(labelH6);
		
		labelH7 = new JLabel("7");
		labelH7.setHorizontalAlignment(SwingConstants.CENTER);
		labelH7.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH7.setBounds(340, 11, 50, 30);
		frame.getContentPane().add(labelH7);
		
		labelH8 = new JLabel("8");
		labelH8.setHorizontalAlignment(SwingConstants.CENTER);
		labelH8.setFont(new Font("Tahoma", Font.PLAIN, 20));
		labelH8.setBounds(390, 11, 50, 30);
		frame.getContentPane().add(labelH8);
		
		startX();
	}
	
	@Override
	public void mousePressed(MouseEvent e)
	{
		super.mousePressed(e);
		
		previousLine = source.getLocation().y / PIECE_SIZE;
		previousColumn = source.getLocation().x / PIECE_SIZE;
	}
	
	@Override
	public void mouseReleased(MouseEvent e) {
		super.mouseReleased(e);
		
		int line = source.getLocation().y / PIECE_SIZE;
		int column = source.getLocation().x / PIECE_SIZE;
		
		if(line == previousLine && column == previousColumn)
			return;
		
		try {
			if(!playHuman(previousLine, previousColumn, line, column))
				playComputer();
			return;
		} catch (WinException e1) {
			labelCurrentPlayer.setText(e1.toString());
			e1.printStackTrace();
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		
		source.setLocation(previousColumn * PIECE_SIZE, previousLine * PIECE_SIZE);
	}
	
	private static Player getOpponent(Player player) {
		if(player == Player.Human)
			return Player.Computer;
		
		return Player.Human;
	}
	
	private void startX() {
	    jpl.Query start = new jpl.Query(new jpl.Compound("startX", new Term[] {new jpl.Variable("B")}));
	    Hashtable<String, Term> solution = start.oneSolution();
	    
	    ArrayList<Piece> pieces = new ArrayList<Piece>();
	    board = (jpl.Compound)solution.get("B");
	    
	    for(int i = 1; i <= 64; ++i) {
	    	jpl.Atom a = (jpl.Atom)board.arg(i);
	    	pieces.add(Piece.getEnum(a.toString()));
	    }
	    
	    recreateField(pieces);
	}

	private void startO() {
	    jpl.Query start = new jpl.Query(new jpl.Compound("startO", new Term[] {new jpl.Variable("B")}));
	    
	    Hashtable<String, Term> solution = start.oneSolution();
	    board = (jpl.Compound)solution.get("B");
	    
	    ArrayList<Piece> pieces = new ArrayList<Piece>();
	    for(int i = 1; i <= 64; ++i) {
	    	jpl.Atom a = (jpl.Atom)board.arg(i);
	    	pieces.add(Piece.getEnum(a.toString()));
	    }
	    
	    recreateField(pieces);
	}
	
	private boolean playHuman(int fromline, int fromcolumn, int toline, int tocolumn) throws Exception {
		if(currentPlayer != Player.Human)
			throw new Exception("It is not the human's turn to play.");
		
	    jpl.Query play = new jpl.Query(new jpl.Compound("playHuman", new Term[] {
	    		board,
	    		jpl.Util.textToTerm(
	    				Integer.toString(fromline + 1) + "/" + Integer.toString(fromcolumn + 1) + "-" + Integer.toString(toline + 1) + "/" + Integer.toString(tocolumn + 1)
	    		),
	    		new jpl.Variable("B"),
	    		new jpl.Variable("C")
	    }));
	    
	    Hashtable<String, Term> solution = play.oneSolution();
	    if(solution == null)
	    	throw new Exception("No solution.");
	    
	    board = (jpl.Compound)solution.get("B");
	    
	    ArrayList<Piece> pieces = new ArrayList<Piece>();
	    for(int i = 1; i <= 64; ++i) {
	    	jpl.Atom a = (jpl.Atom)board.arg(i);
	    	pieces.add(Piece.getEnum(a.toString()));
	    }
	    
	    recreateField(pieces);
	    
	    boolean cont = ((jpl.Atom)solution.get("C")).toString().equals("true");
	    if(!cont) {
	    	currentPlayer = Player.Computer;
	    	labelCurrentPlayer.setText("Computador");
	    }
	    
	    return cont;
	}

	private void playComputer() throws Exception {
		if(gameOver())
			throw new WinException(getOpponent(currentPlayer));
		
		if(currentPlayer != Player.Computer)
			throw new Exception("It is not the computer's turn to play.");
		
	    jpl.Query play = new jpl.Query(new jpl.Compound("playComputer", new Term[] {
	    		board,
	    		new jpl.Variable("B"),
	    		new jpl.Variable("C")
	    }));
	    
	    Hashtable<String, Term> solution = play.oneSolution();
	    if(solution == null)
	    	throw new Exception("No solution.");
	    
	    board = (jpl.Compound)solution.get("B");
	    ArrayList<Piece> pieces = new ArrayList<Piece>();
	    for(int i = 1; i <= 64; ++i) {
	    	jpl.Atom a = (jpl.Atom)board.arg(i);
	    	pieces.add(Piece.getEnum(a.toString()));
	    }
	    
	    boolean cont = ((jpl.Atom)solution.get("C")).toString().equals("true");
	    if(cont) {
	    	playComputer();
	    	return;
	    }
	    
    	currentPlayer = Player.Human;
    	labelCurrentPlayer.setText("Humano");
    	recreateField(pieces);
		if(gameOver())
			throw new WinException(getOpponent(currentPlayer));
	}
	
	private boolean gameOver() {
		String current = "humano";
		if(currentPlayer == Player.Computer)
			current = "computador";
		
	    jpl.Query gameover = new jpl.Query(new jpl.Compound("boardGameOver", new Term[] {
	    		board,
	    		new jpl.Atom(current)
	    }));
	    
	    return gameover.hasSolution();
	}
	
	private void recreateField(ArrayList<Piece> pieces) {
		boardPanel.removeAll();
		boardPanel.repaint();
		
		JLabel lblBoard = new JLabel(BOARD_IMAGE);
		lblBoard.setBounds(0, 0, 400, 400);
		boardPanel.add(lblBoard);
		
		for(int i = 0; i < 64; ++i) {			
			Piece p = pieces.get(i);
			if(p == Piece.Invalid || p == Piece.Empty)
				continue;
			
			JLabel piece = new JLabel(PIECE_IMAGE.get(p));
			boardPanel.add(piece);
			boardPanel.setComponentZOrder(piece, 0);
			piece.setSize(PIECE_SIZE, PIECE_SIZE);
			piece.setLocation(PIECE_SIZE * (i % 8), PIECE_SIZE * (i / 8));
			registerComponent(piece);
		}
	}
}
