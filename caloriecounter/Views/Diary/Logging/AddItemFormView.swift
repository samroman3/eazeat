//
//  AddItemFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct AddItemFormView: View {
    @Binding var isPresented: Bool
    var selectedDate: Date
    @Binding var mealType: String
    @State private var name: String = ""
    var dataStore: NutritionDataStore?
    let onDismiss: () -> Void
    
    @State private var userNote: String = "Enter a note..."
    @State private var mealPhoto: UIImage?
    @State private var showImagePicker = false
    @State private var microNutrientsExpanded = false
    @State private var notesExpanded = false
    @FocusState private var focusedField: FocusableField?
    
    @State private var showingPreviousEntries = false

    enum FocusableField {
        case name, nutrientInput
    }
    
    @State private var nutrientValues: [NutrientType: String] = [
        .calories: "0", .protein: "0", .carbs: "0", .fats: "0", .vitaminA: "0", .vitaminC: "0", .vitaminD: "0", .vitaminE: "0", .vitaminB6: "0", .vitaminB12: "0", .folate: "0", .calcium: "0", .iron: "0", .magnesium: "0", .phosphorus: "0", .potassium: "0", .sodium: "0", .zinc: "0"
    ]
    
    // Subset for macronutrients
    let macroNutrientTypes: [NutrientType] = [.calories, .protein, .carbs, .fats]
    let additionalVitaminTypes: [NutrientType] = [.vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminB6, .vitaminB12, .folate]
    let mineralTypes: [NutrientType] = [.calcium, .iron, .magnesium, .phosphorus, .potassium, .sodium, .zinc]
    
    enum NutrientType: String, CaseIterable {
        case calories, protein, carbs, fats,
             vitaminA, vitaminC, vitaminD, vitaminE, vitaminB6, vitaminB12, folate,
             calcium, iron, magnesium, phosphorus, potassium, sodium, zinc
    }
    
    @State private var selectedNutrient: NutrientType?
    
    
    
    @FocusState private var isInputActive: Bool
    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isUserNoteFocused: Bool
    @State private var isEditing: Bool = false
    let columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 200, maximum: 500)), count: 2)
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center){
                Button(action: { isPresented = false }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textColor)
                            }.padding([.vertical,.horizontal])

            }
            HStack {
                TextField("Enter Name...", text: $name)
                    .focused($isNameTextFieldFocused)
                    .foregroundColor(AppTheme.textColor)
                    .font(.title3)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .onChange(of: isNameTextFieldFocused, 
                              perform: { isFocused in
                        showingPreviousEntries = isFocused
                    })
                Image(systemName: "star")
                    .foregroundColor(.yellow)
            }
            .padding([.horizontal, .vertical])
                if showingPreviousEntries {
                        PreviousEntriesView(name: $name, dataStore: dataStore)
                    Spacer()
                } else {
                    ScrollView(.vertical){
                    if !isUserNoteFocused {
                        // Nutrient input section
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(macroNutrientTypes, id: \.self) { nutrient in
                                MacroNutrientInputTile(
                                    nutrient: nutrient,
                                    value: $nutrientValues[nutrient],
                                    isSelected: Binding(
                                        get: { selectedNutrient == nutrient },
                                        set: { _ in selectedNutrient = nutrient }
                                    ),
                                    isInputActive: _isInputActive
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer()
                        if !isUserNoteFocused {
                            Button {
                                microNutrientsExpanded.toggle()
                            } label: {
                                Image(systemName: "chevron.down.circle")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(AppTheme.textColor)
                                Text("More")
                                    .foregroundStyle(AppTheme.textColor)
                            }
                            if microNutrientsExpanded == true && isNameTextFieldFocused == false {
                                // Vitamins and Minerals form section
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHGrid(rows: [GridItem(.flexible())]) {
                                        if microNutrientsExpanded {
                                            ForEach(additionalVitaminTypes, id: \.self) { nutrient in
                                                AdditionalNutrientInputRow(nutrient: nutrient, value: $nutrientValues[nutrient], isSelected:  Binding(
                                                    get: { selectedNutrient == nutrient },
                                                    set: { _ in selectedNutrient = nutrient }
                                                ),isInputActive: _isInputActive)
                                                .background(AppTheme.reverse)
                                            }
                                            ForEach(mineralTypes, id: \.self) { nutrient in
                                                AdditionalNutrientInputRow(nutrient: nutrient, value: $nutrientValues[nutrient], isSelected:  Binding(
                                                    get: { selectedNutrient == nutrient },
                                                    set: { _ in selectedNutrient = nutrient }
                                                ), isInputActive: _isInputActive)

                                            }
                                        }
                                    }.frame(height: 150)
                                }
                            }
                        }
                        if isInputActive == false {
                            Button {
                                notesExpanded.toggle()
                            } label: {
                                Image(systemName:"square.and.pencil.circle")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(AppTheme.basic)
                                Text("")
                                    .foregroundStyle(AppTheme.basic)
                            }
                            if isNameTextFieldFocused == false && notesExpanded == true {
                                TextField("Enter a note...", text: $userNote)
                                    .focused($isUserNoteFocused)
                                    .foregroundColor(AppTheme.textColor)
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(0)
                                    .padding(.horizontal)
                                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                                    .background(AppTheme.reverse.edgesIgnoringSafeArea([.leading,.trailing]))
                            }
                            if !isUserNoteFocused {
                                Button {
                                    self.showImagePicker.toggle()
                                } label: {
                                    Image(systemName: "photo.artframe.circle")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(AppTheme.textColor)
                                    Text("")
                                        .foregroundStyle(AppTheme.textColor)
                                }
                            }
                        }
                        
                    }.padding(.horizontal)
                    
                    
                    //TODO: view for selected image
                    //                        mealPhoto.map { image in
                    //                            Image(uiImage: image)
                    //                                .resizable()
                    //                        } ?? Image(systemName: "photo.badge.plus.fill")
                    
                }
            }
            HStack {
                if !isNameTextFieldFocused && !isUserNoteFocused {
                    TextField("Enter value", text: selectedNutrientTextBinding(), onEditingChanged: { isEditing in
                        if isEditing && self.nutrientValues[selectedNutrient!] == "0" {
                            self.nutrientValues[selectedNutrient!] = ""
                        }
                    })
                    .keyboardType(.decimalPad)
                    .focused($isInputActive)
                    .font(.largeTitle)
                    .frame(height: 70)
                    .fontWeight(.light)
                    .padding(.horizontal)
                    .foregroundColor(AppTheme.textColor)
                    Spacer()
                }
                if keyBoardOpen() {
                    Button(action: {
                        hideKeyboard()
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(AppTheme.textColor)
                    })
                    .padding([.vertical])
                }
            }
            
            // 'Add' button
            if !keyBoardOpen() {
                Button(action: { addFoodItem(nutrientValues)
                    isPresented = false
                    onDismiss()
                }) {
                    Text("Add")
                        .font(.title)
                        .fontWeight(.light)
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.lavender)
                        .foregroundColor(.white)
                }
            }
        }
//        .gesture(
//                DragGesture().onChanged { value in
//                    if !showingPreviousEntries {
//                    // Check if the drag is a downward swipe
//                    if value.translation.height > 10 {
//                        // Dismiss the keyboard
//                        focusedField = nil
//                        hideKeyboard()
//                    }
//                }
//            }
//        )
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$mealPhoto)
        }
        .onAppear {
            selectedNutrient = .calories
        }
    }
    
    private func selectedNutrientTextBinding() -> Binding<String> {
        Binding<String>(
            get: { self.nutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
            set: { self.nutrientValues[self.selectedNutrient ?? .calories] = $0 }
        )
    }

    
    struct AdditionalNutrientInputRow: View {
        let nutrient: NutrientType
        @Binding var value: String?
        @Binding var isSelected: Bool
        @FocusState var isInputActive: Bool

        var body: some View {
            Button(action: {
                isSelected = true
                isInputActive = true
            }) {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        HStack {
                            Text(value ?? "")
                            Text("mg")
                        }
                        .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                        .font(.headline)
                        .fontWeight(.light)
                        Text(nutrient.rawValue)
                    }
                    .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                }
                .padding([.vertical,.horizontal])
                .frame(minWidth: 150, maxHeight: .infinity)
                .background(isSelected ? AppTheme.basic : AppTheme.grayMiddle)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
    }
    
    struct MacroNutrientInputTile: View {
        let nutrient: NutrientType
        @Binding var value: String?
        @Binding var isSelected: Bool
        @FocusState var isInputActive: Bool
        
        var body: some View {
            Button(action: {
                isSelected = true
                isInputActive = true
            }) {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        HStack {
                            Text(value ?? "")
                            Text("g")
                        }
                        .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.basic)
                        .font(.headline)
                        .fontWeight(.bold)
                        Text(nutrient.rawValue)
                    }
                    .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                }
                .padding([.vertical,.horizontal],50)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(isSelected ? AppTheme.basic : AppTheme.grayMiddle)
                .clipShape(.rect(cornerRadius: 20))
                .padding()
                .shadow(radius: 4, x: 2, y: 4)
            }
        }
    }

    private func keyBoardOpen() -> Bool {
        return focusedField != nil || isInputActive || isNameTextFieldFocused || isUserNoteFocused
    }
    
    enum KeyboardType {
        case numeric
        case alphabet
    }
    private func addFoodItem(_ nutrientValues: [NutrientType: String]) {
        guard !self.name.isEmpty || self.name != "" else {
            //todo: handle error
            return
        }
        //macros
        guard let caloriesValue = Double(nutrientValues[.calories] ?? "0"),
              let proteinValue = Double(nutrientValues[.protein] ?? "0"),
              let carbsValue = Double(nutrientValues[.carbs] ?? "0"),
              let fatValue = Double(nutrientValues[.fats] ?? "0") else {
            print("invalid input")
            return
        }
        
        dataStore?.addEntryToMealAndDailyLog(
            date: selectedDate,
            mealType: mealType,
            name: name,
            calories: Double(nutrientValues[.calories] ?? "0") ?? 0,
            protein: Double(nutrientValues[.protein] ?? "0") ?? 0,
            carbs: Double(nutrientValues[.carbs] ?? "0") ?? 0,
            fat: Double(nutrientValues[.fats] ?? "0") ?? 0,
            sugars: 0,
            addedSugars: 0,
            cholesterol: 0,
            sodium: 0,
            vitamins: [:],
            minerals: [:],
            servingSize: "1 serving",
            foodGroup: "Grains",
            userNotes: userNote,
            mealPhoto: mealPhoto?.jpegData(compressionQuality: 1.0) ?? Data(),
            mealPhotoLink: "" //TODO: generate a link
        )
        print("adding food entry: name: \(name), type:\(mealType) , cals:\(caloriesValue), protein:\(proteinValue), carbs: \(carbsValue), fats: \(fatValue)")
        return
    }
    
}


struct PreviousEntriesView: View {
@State private var selectedTab: Int = 0
@Binding var name: String
@State var dataStore: NutritionDataStore?
@State private var entries: [NutritionEntry] = []
@State private var favoriteEntries: [NutritionEntry] = []

var body: some View {
    VStack {
        Picker("Filter", selection: $selectedTab) {
            Text("All").tag(0)
            Text("Favorites").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedTab) { _ in
            fetchEntries()
        }

        ScrollView {
                ForEach(selectedTab == 0 ? entries : favoriteEntries, id: \.self) { entry in
                    NutritionEntryView(entry: entry)
                }
        }
    }
    .onChange(of: name) { _ in
        fetchEntries()
        
    }
    .onAppear {
        fetchEntries()
    }
}
    private func fetchEntries() {
     if selectedTab == 0 {
         entries = dataStore?.fetchEntries(favorites: false, nameSearch: name) ?? []
         print(entries)
     } else {
         favoriteEntries = dataStore?.fetchEntries(favorites: true) ?? []
     }
 }
}


struct SimpleNutritionEntry: Identifiable, Hashable {
    let id: UUID
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
}

// Mock NutritionDataStore for preview purposes
class MockNutritionDataStore: NutritionDataStore {
    func fetchEntries(favorites: Bool, nameSearch: String? = nil) -> [SimpleNutritionEntry] {
        // Return dummy entries based on the nameSearch parameter
        let dummyEntries = [
            SimpleNutritionEntry(id: UUID(), name: "Apple", calories: 95, protein: 0.5, carbs: 25, fats: 0.3),
            SimpleNutritionEntry(id: UUID(), name: "Banana", calories: 105, protein: 1.3, carbs: 27, fats: 0.3),
            SimpleNutritionEntry(id: UUID(), name: "Carrot", calories: 25, protein: 0.6, carbs: 6, fats: 0.1),
            SimpleNutritionEntry(id: UUID(), name: "Date", calories: 20, protein: 0.2, carbs: 5, fats: 0.03)
        ]
        
        if let nameSearch = nameSearch, !nameSearch.isEmpty {
            return dummyEntries.filter { $0.name.lowercased().contains(nameSearch.lowercased()) }
        }
        return dummyEntries
    }
}

// Updated AddItemFormView_Previews with a mock data store
struct AddItemFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemFormView(
            isPresented: .constant(true),
            selectedDate: Date(),
            mealType: .constant("Breakfast"),
            dataStore: MockNutritionDataStore(context: PersistenceController(inMemory: false).container.viewContext), onDismiss: {}
        )
    }
}