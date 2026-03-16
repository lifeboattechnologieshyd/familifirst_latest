//
//  EventsCell.swift
//  FamilyFirst
//

import UIKit

class EventsCell: UITableViewCell {

    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var eventnameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        backgroundColor = .white
        
        guard let bgVw = bgVw else { return }
        
        bgVw.backgroundColor = .white
        bgVw.layer.cornerRadius = 12
        bgVw.layer.shadowColor = UIColor.black.cgColor
        bgVw.layer.shadowOpacity = 0.1
        bgVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgVw.layer.shadowRadius = 4
        bgVw.clipsToBounds = false
        
        [img1, img2, img3].forEach { imageView in
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.layer.borderWidth = 2
            imageView?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img1?.layer.cornerRadius = (img1?.frame.height ?? 30) / 2
        img2?.layer.cornerRadius = (img2?.frame.height ?? 30) / 2
        img3?.layer.cornerRadius = (img3?.frame.height ?? 30) / 2
        moreBtn?.layer.cornerRadius = (moreBtn?.frame.height ?? 30) / 2
    }
    
    func configure(with event: Event) {
        eventnameLbl?.text = event.eventName
        
        if let eventDate = event.eventDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateLbl?.text = dateFormatter.string(from: eventDate)
        } else {
            dateLbl?.text = event.date
        }
        
        if let eventDate = event.eventDate {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            dayFormatter.locale = Locale(identifier: "en_US_POSIX")
            dayLbl?.text = dayFormatter.string(from: eventDate)
        } else {
            dayLbl?.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moreBtn?.setTitle("", for: .normal)
        eventnameLbl?.text = ""
        dateLbl?.text = ""
        dayLbl?.text = ""
    }
    
    private func loadImage(for imageView: UIImageView?, from urlString: String?) {
        guard let imageView = imageView else { return }
        
        imageView.image = UIImage(named: "Picture")
        
        if let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
