//
//  DialyEdit.swift
//  LifeLog
//
//  Created by Genki on 11/7/23.
//

import SwiftUI
import CoreData

struct DiaryEditView: View {
    @State private var showingAlert = false
    @State var photos: [UIImage] = []
    @State var inputImage: [UIImage] = []
    @State var showingImagePicker = false
    @Binding var date: Date
    @State var diary = ""
    @FetchRequest(sortDescriptors: []) var calendarItems: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    @FetchRequest(sortDescriptors: []) var dateFullItem: FetchedResults<DateItem>
    @Environment(\.managedObjectContext) var viewContext
    @State var edit = false
    @Environment(\.dismiss) private var dismiss
    @StateObject var photoPickerViewModel = PhotoPickerViewModel()
    @AppStorage("imageData") var imageData = 0.0
    @State var beforeTotalSize = 0.0
    @State var afterTotalSIze = 0.0
    @State private var showPremium = false
    @State private var showDatePicker = false
    @State var datePickerDate = Date()
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @FocusState private var focused: Bool
    @State var pickerEnd = false
    @State private var scrollView: ScrollViewProxy?
    let startDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
    let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    ScrollView {
                        Rectangle()
                            .frame(width: 100, height: 10)
                            .foregroundColor(.clear)
                        VStack(alignment: .leading) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(0..<photos.count, id: \.self) { index in
                                        Button {
                                            withAnimation(.easeInOut) {
                                                focused = false
                                                photoPickerViewModel.selectedImageID = index
                                                photoPickerViewModel.showImageViewer.toggle()
                                            }
                                        } label: {
                                            Image(uiImage: photos[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Rectangle())
                                                .padding(.leading, index == 0 ? 16 : 0)
                                        }
                                    }
                                }
                            }
                            TextField("What happened?", text: $diary, axis: .vertical)
                                .padding(.horizontal)
                                .focused($focused)

                            Rectangle()
                                .frame(height: 200)
                                .foregroundStyle(Color("whiteBlack"))
                        }
                        .onAppear {
                            if let item = getDateItem(date: date)?.first {
                                diary = item.dialy!
                                edit = true
                                if let imageData = item.images {
                                    photos = imagesFromCoreData(object: imageData)!
                                    for image in imagesFromCoreData(object: imageData)! {
                                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                                            let imageSizeInMB = Double(imageData.count) / 1024.0 / 1024.0
                                            beforeTotalSize += imageSizeInMB
                                        }
                                    }
                                }
                            }
                            datePickerDate = date
                        }
                        .onChange(of: date) { displayDate in
                            if let item = getDateItem(date: displayDate)?.first {
                                diary = item.dialy!
                                edit = true
                                if let imageData = item.images {
                                    photos = imagesFromCoreData(object: imageData)!
                                }
                            } else {
                                diary = ""
                                photos = []
                                edit = false
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                            ToolbarItem(placement: .principal) {
                                DatePicker("",
                                           selection: $date,
                                           in: startDate...endDate,
                                           displayedComponents: [.date]
                                            )
                                .labelsHidden()
                            }
                        }
                    .navigationBarItems(leading: Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    }), trailing: Button {
                        showingAlert = true
                    } label: {
                        if edit {
                            if let item = getDateItem(date: date)?.first {
                                if item.dialy != "" && item.images != nil {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    })
                    .onChange(of: focused) { isFocused in
                        if isFocused {
                            scrollToBottom()
                        }
                    }
                    .onChange(of: diary) { _ in
                        if focused {
                            scrollToBottom()
                        }
                               }
                    VStack(spacing: 0) {
                        Spacer()
                        Divider()
                        HStack(spacing: 14) {
                            if focused == true {
                                Button {
                                    focused = false
                                } label: {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                        .foregroundColor(Color("iconColor"))
                                        .font(.system(size: 22))
                                }
                            }
                            Spacer()
                            Button {
                                if imageData > 150 && !entitlementManager.hasPro {
                                    showPremium = true
                                } else {
                                    showingImagePicker = true
                                }
                            } label: {
                                Image(systemName: "camera")
                                    .foregroundColor(Color("iconColor"))
                                    .font(.system(size: 22))
                            }
                            Button {
                                if diary != "" {
                                    if edit {
                                        if let firstDateItem = getDateItem(date: date)?.first {
                                                editEvent(event: firstDateItem)
                                        }
                                    } else {
                                        addEvent()
                                    }
                                    dismiss()
                                    if photos != [] {
                                        for image in photos {
                                            if let imageData = image.jpegData(compressionQuality: 1.0) {
                                                let imageSizeInMB = Double(imageData.count) / 1024.0 / 1024.0
                                                afterTotalSIze += imageSizeInMB
                                            }
                                        }
                                    } else {
                                        afterTotalSIze = 0
                                    }
                                    imageData = (imageData - beforeTotalSize) + afterTotalSIze
                                }
                            } label: {
                                Text("Save")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(saveColor().cornerRadius(100))
                                    .foregroundColor(diary != "" ?
                                                     Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1))
                                                     : Color(UIColor.secondaryLabel))
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color("whiteBlack"))
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    PhotoPicker(photos: $photos, selectionLimit: 5)
                        .edgesIgnoringSafeArea(.bottom)
                }

                .environmentObject(photoPickerViewModel)
            }
            PhotoDetailView(images: $photos)
                .environmentObject(photoPickerViewModel)
        }
        .background(
            ScrollViewReader { proxy in
                Color.clear
                    .onAppear {
                        scrollView = proxy
                    }
            }
        )

        .fullScreenCover(isPresented: $showPremium) {
            PremiumView()
        }
        .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Delete"),
                          message: Text("Are you sure you want to delete this diary entry?"),
                          primaryButton: .cancel(Text("Cancel")),    // キャンセル用
                          secondaryButton: .destructive(Text("Delete"), action: {
                        if let deleteItem = dateItem.first {
                            deleteEvent(event: deleteItem)
                            imageData -= beforeTotalSize
                            if getCalendarItem(date: date).count == 0 {
                                if let dateItem = getDateItem(date: date)?.first {
                                    editDateItem(event: dateItem)
                                }
                            }
                        }
                        dismiss()
                    }))
                }
    }
}

func coreDataObjectFromImages(images: [UIImage]) -> Data? {
    let dataArray = NSMutableArray()
    for img in images {
        if let data = img.jpegData(compressionQuality: 0.3) {
            dataArray.add(data)
        }
    }
    return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
}

func imagesFromCoreData(object: Data?) -> [UIImage]? {
    var retVal = [UIImage]()

    guard let object = object else { return nil }
    if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSData.self], from: object) {
        if let sequence = dataArray as? NSArray {
            for data in sequence {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
    }
    return retVal
}

extension DiaryEditView {
    private func scrollToBottom() {
        if let scrollView = scrollView {
            withAnimation {
                scrollView.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
    private func saveColor() -> Color {
        if diary == "" {
            return Color(UIColor.systemFill)
        } else {
            return Color("buttonColor")
        }
    }
    private func loadImage() {
        print(inputImage)
        let newImages = inputImage
        let inputImageData = coreDataObjectFromImages(images: newImages)
        let addImages = imagesFromCoreData(object: inputImageData)
        if let images = addImages {
            for image in images where !photos.contains(image) {
                photos.append(image)
            }
        }
        inputImage = []
    }
    private func getDateItem(date: Date) -> FetchedResults<DateItem>? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let predicate = NSPredicate(format: "(%@ <= date) AND (date <= %@)", targetDate as NSDate, targetDate as NSDate)
        dateItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return dateItem
    }
    private func addEvent() {
        let newItem = DateItem(context: viewContext)
        newItem.date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        newItem.dialy = diary
        newItem.adequancy = Int16(-1)
        newItem.images = coreDataObjectFromImages(images: photos)
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func editEvent(event: FetchedResults<DateItem>.Element) {
        event.dialy = diary
        event.images = coreDataObjectFromImages(images: photos)
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }

    private func editDateItem(event: FetchedResults<DateItem>.Element) {
        if getCalendarItem(date: date).count == 0 {
            event.adequancy = -1
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return calendarItems
    }
    private func deleteEvent(event: FetchedResults<DateItem>.Element) {
        event.dialy = ""
        event.images = nil
        if getCalendarItem(date: date).count == 0 {
            viewContext.delete(event)
        }
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
}
